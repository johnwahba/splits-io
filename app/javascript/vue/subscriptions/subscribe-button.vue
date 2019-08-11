<template>
  <div>
    <button class="btn btn-lg btn-block btn-primary disabled"
      v-if="!currentUser && action === 'subscribe'"
      type="button" disabled>
      Sign in to subscribe
    </button>
    <button class="btn btn-lg btn-block btn-outline-light disabled"
      v-if="priceCents === 0" type="button" disabled>
      Active
    </button>
    <button class="btn btn-lg btn-block btn-outline-danger"
      v-if="currentUser && action === 'cancel'"
      type='button' @click="cancel" :disabled="loading || completed">
      <template v-if='loading'><spinner></spinner></template>
      <template v-else-if='completed'><i class="fas fa-check"></i></template>
      <template v-else>Cancel</template>
    </button>
    <button class="btn btn-lg btn-block btn-primary"
      v-if="currentUser && action === 'subscribe'"
      type="button" @click="subscribe" :disabled='loading || completed'>
      <template v-if='loading'><spinner></spinner></template>
      <template v-else-if='completed'><i class="fas fa-check"></i></template>
      <template v-else>Subscribe</template>
      <div id="error-message"></div>
    </button>
    <button class="btn btn-lg btn-block btn-outline-primary"
      v-if="currentUser && action === 'upgrade'"
      type="button" @click="upgrade" :disabled='loading || completed'>
      <template v-if='loading'><spinner></spinner></template>
      <template v-else-if='completed'><i class="fas fa-check"></i></template>
      <template v-else>Switch to this plan</template>
      <div id="error-message"></div>
    </button>
    <button class="btn btn-lg btn-block btn-outline-primary"
      v-if="currentUser && action === 'downgrade'"
      type="button" @click="downgrade" :disabled='loading || completed'>
      <template v-if='loading'><spinner></spinner></template>
      <template v-else-if='completed'><i class="fas fa-check"></i></template>
      <template v-else>Switch to this plan</template>
      <div id="error-message"></div>
    </button>
    <button class="btn btn-lg btn-block btn-outline-light disabled"
      v-if="currentUser && action === 'canceled'"
      type="button" v-tippy style="cursor: default"
      title="Your subscription has been canceled. It will last until the end of your billing cycle.">
      Canceled
    </button>
  </div>
</template>

<script>
import spinner from '../spinner.vue'

export default {
  components: { spinner },
  data: function() {
    return {
      completed: false,
      loading: false,
    }
  },
  methods: {
    cancel: async function() {
      this.loading = true

      await fetch('/subscriptions', {method: 'DELETE'})

      this.completed = true
      this.loading = false

      location.reload()
    },
    downgrade: async function() {
      this.loading = true

      await fetch('/subscriptions', {
        method: 'PATCH',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({plan: 'downgrade'}),
      })

      this.completed = true
      this.loading = false
      location.reload()
    },
    subscribe: async function() {
      this.loading = true

      const stripe = Stripe(this.stripePublishableKey)
      const result = await stripe.redirectToCheckout({
        items: [{plan: this.planId, quantity: 1}],
        successUrl: `${location.origin}/subscriptions/success?session_id={CHECKOUT_SESSION_ID}`,
        cancelUrl: `${location.origin}/subscriptions/cancel`,
        clientReferenceId: this.currentUser.id,
        customerEmail: this.currentUser.email,
      })

      if (result.error) {
        document.getElementById('error-message').textContent = result.error.message;
      }

      this.completed = true
      this.loading = false
    },
    upgrade: async function() {
      this.loading = true

      await fetch('/subscriptions', {
        method: 'PATCH',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({plan: 'upgrade'}),
      })

      this.completed = true
      this.loading = false
      location.reload()
    },
  },
  name: 'subscribe-button',
  props: ['plan-id', 'action', 'current-user', 'price-cents', 'stripe-publishable-key'],
}
</script>
