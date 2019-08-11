<template>
  <div class="card-deck mb-3 text-center">
    <plan v-bind="bronzePlan" :current-user='currentUser' :stripe-publishable-key='stripePublishableKey'></plan>
    <plan v-bind="silverPlan" :current-user='currentUser' :stripe-publishable-key='stripePublishableKey'></plan>
    <plan v-bind="goldPlan" :current-user='currentUser' :stripe-publishable-key='stripePublishableKey'></plan>
  </div>
</template>

<script>
import plan from './plan.vue'

export default {
  components: { plan },
  computed: {
    currentUser: function() {
      return {
        id: this.currentUserId,
        email: this.currentUserEmail,
      }
    },
    bronzePlan: function() {
      return {
        action: 'active',
        name: 'Basic',
        priceCents: 0,
      }
    },
    silverPlan: function() {
      var action
      if (this.currentPlan === this.silverPlanId && this.currentPlanStatus === 'active') {
        action = 'cancel'
      } else if (this.currentPlan === this.silverPlanId && this.currentPlanStatus === 'canceled') {
        action = 'canceled'
      } else if (this.currentPlan === this.goldPlanId) {
        action = 'downgrade'
      } else {
        action = 'subscribe'
      }

      return {
        action: action,
        id: this.silverPlanId,
        name: 'Gold',
        priceCents: 400,
      }
    },
    goldPlan: function() {
      var action
      if (this.currentPlan === this.silverPlanId) {
        action = 'upgrade'
      } else if (this.currentPlan === this.goldPlanId && this.currentPlanStatus === 'canceled') {
        action = 'canceled'
      } else if (this.currentPlan === this.goldPlanId) {
        action = 'cancel'
      } else {
        action = 'subscribe'
      }

      return {
        action: action,
        id: this.goldPlanId,
        name: 'Noclip',
        priceCents: 600,
      }
    }
  },
  name: 'subscription',
  props: [
    'current-user-id',
    'current-user-email',
    'current-plan',
    'current-plan-status',
    'stripe-publishable-key',
    'silver-plan-id',
    'gold-plan-id'
  ],
}
</script>
