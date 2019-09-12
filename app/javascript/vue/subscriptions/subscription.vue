<template>
  <div class="card-deck mb-3 text-center">
    <plan v-bind="basicPlan"  :current-user='currentUser' :stripe-publishable-key='stripePublishableKey'></plan>
    <plan v-bind="goldPlan"   :current-user='currentUser' :stripe-publishable-key='stripePublishableKey'></plan>
    <plan v-bind="noclipPlan" :current-user='currentUser' :stripe-publishable-key='stripePublishableKey'></plan>
  </div>
</template>

<script>
import plan from './plan.vue'

export default {
  components: { plan },
  computed: {
    currentUser: function() {
      return this.currentUserId ? {
        id: this.currentUserId,
        email: this.currentUserEmail,
      } : null
    },
    basicPlan: function() {
      return {
        action: 'active',
        name: 'Basic',
        priceCents: 0,
      }
    },
    goldPlan: function() {
      var action
      if (this.currentPlan === this.goldPlanId && this.currentPlanStatus === 'active') {
        action = 'cancel'
      } else if (this.currentPlan === this.goldPlanId && this.currentPlanStatus === 'canceled') {
        action = 'canceled'
      } else if (this.currentPlan === this.noclipPlanId) {
        action = 'downgrade'
      } else {
        action = 'subscribe'
      }

      return {
        action: action,
        id: this.goldPlanId,
        name: 'Gold',
        priceCents: 400,
      }
    },
    noclipPlan: function() {
      var action
      if (this.currentPlan === this.goldPlanId) {
        action = 'upgrade'
      } else if (this.currentPlan === this.noclipPlanId && this.currentPlanStatus === 'canceled') {
        action = 'canceled'
      } else if (this.currentPlan === this.noclipPlanId) {
        action = 'cancel'
      } else {
        action = 'subscribe'
      }

      return {
        action: action,
        id: this.noclipPlanId,
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
    'gold-plan-id',
    'noclip-plan-id'
  ],
}
</script>
