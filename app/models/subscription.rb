class Subscription < ActiveRecord::Base
  belongs_to :user

  scope :active,   -> { where(ended_at: nil) }
  scope :canceled, -> { where.not(canceled_at: nil) }
  scope :tier1,    -> { where(stripe_plan_id: [ENV['STRIPE_PLAN_ID_TIER1'], ENV['STRIPE_PLAN_ID_TIER2']]) }
  scope :tier2,    -> { where(stripe_plan_id: ENV['STRIPE_PLAN_ID_TIER2']) }

  def canceled?
    canceled_at.present?
  end

  def ended?
    ended_at.present?
  end

  def upgrade!
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']

    # First we need the Subscription Item ID
    subscription = Stripe::Subscription.retrieve(stripe_subscription_id)

    Stripe::Subscription.update(
      stripe_subscription_id,
      cancel_at_period_end: false,
      items: [{
        id: subscription.items.data[0].id,
        plan: ENV['STRIPE_PLAN_ID_TIER2'],
      }],
    )
    update(
      canceled_at: nil,
      stripe_plan_id: ENV['STRIPE_PLAN_ID_TIER2'],
    )
  end

  def downgrade!
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']

    # First we need the Subscription Item ID
    subscription = Stripe::Subscription.retrieve(stripe_subscription_id)

    Stripe::Subscription.update(
      stripe_subscription_id,
      cancel_at_period_end: false,
      items: [{
        id: subscription.items.data[0].id,
        plan: ENV['STRIPE_PLAN_ID_TIER1']
      }],
    )
    update(
      canceled_at: nil,
      stripe_plan_id: ENV['STRIPE_PLAN_ID_TIER1'],
    )
  end

  def cancel!
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    Stripe::Subscription.update(
      stripe_subscription_id,
      cancel_at_period_end: true,
    )
    update(canceled_at: Time.now.utc)
  end

  def self.cancel_all!
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']

    where(canceled_at: nil).find_each do |subscription|
      Stripe::Subscription.update(
        subscription.stripe_subscription_id,
        cancel_at_period_end: true,
      )
    end

    # Set canceled_at now; ended_at will be set by a Stripe webhook when the month runs out
    where(canceled_at: nil).update_all(canceled_at: Time.now.utc)
  end
end
