class Subscription < ActiveRecord::Base
  belongs_to :user

  scope :active,   -> { where(ended_at: nil) }
  scope :canceled, -> { where.not(canceled_at: nil) }
  scope :silver,   -> { where(stripe_plan_id: ENV['STRIPE_SILVER_PLAN_ID']) }
  scope :gold,     -> { where(stripe_plan_id: ENV['STRIPE_GOLD_PLAN_ID']) }

  def type
    case stripe_plan_id
    when ENV['STRIPE_SILVER_PLAN_ID']
      :silver
    when ENV['STRIPE_GOLD_PLAN_ID']
      :gold
    end
  end

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
        plan: ENV['STRIPE_GOLD_PLAN_ID'],
      }],
    )
    update(
      canceled_at: nil,
      stripe_plan_id: ENV['STRIPE_GOLD_PLAN_ID'],
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
        plan: ENV['STRIPE_SILVER_PLAN_ID']
      }],
    )
    update(
      canceled_at: nil,
      stripe_plan_id: ENV['STRIPE_SILVER_PLAN_ID'],
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
