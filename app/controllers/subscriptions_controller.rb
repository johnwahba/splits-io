class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: %i[update destroy]

  def index
  end

  def show
  end

  def update
    case params[:plan]
    when 'upgrade'
      @subscription.upgrade!
    when 'downgrade'
      @subscription.downgrade!
    end

    head :ok
  end

  # This endpoint is only hit by first party JavaScript
  def destroy
    @subscription.cancel!

    head :no_content
  end

  private

  def set_subscription
    @subscription = current_user.subscriptions.active.first
  end
end
