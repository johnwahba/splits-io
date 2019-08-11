<template>
  <div class="card">
    <div class="card-header">
      <h4 class="my-0 font-weight-normal">
        {{name}}
        <template v-if="action === 'cancel'">
          -
          <span class="text-primary">Active</span>
        </template>
      </h4>
    </div>
    <div class="card-body">
      <h1 class="card-title pricing-card-title">
        <template v-if="priceCents === 0">
          Free
        </template>
        <template v-else>
          ${{(priceCents || 0) / 100}}
          <small class="text-muted">/ mo</small>
        </template>
      </h1>
      <ul class="list-unstyled mt-3 mb-4">
        <li v-for='feature in features'>
          {{feature.description}}
          <span v-if='feature.details' v-tippy=true :title='feature.details'>[?]</span>
        </li>
      </ul>
    </div>
    <div class="card-footer">
      <subscribe-button :plan-id='id' :current-user='currentUser' :action='action' :price-cents='priceCents' :stripe-publishable-key='stripePublishableKey'>
      </subscribe-button>
    </div>
  </div>
</template>

<script>
import subscribeButton from './subscribe-button.vue'

export default {
  components: { subscribeButton },
  computed: {
    features: function() {
      switch(this.name) {
        case 'Basic':
          return [
            {description: 'Basic analytics'},
            {description: 'Ad-supported'},
          ]
        case 'Gold':
          return [
            {description: 'Disable ads'},
            {description: 'Predict when you\'ll PB'},
          ]
        case 'Noclip':
          return [
            {description: 'Disable ads'},
            {description: 'Predict when you\'ll PB'},
            {
              description: 'Upgrade permalinks to redirectors',
              details: 'Permalink redirectors are links that always redirect to your PB, even when it improves.'
            },
            {description: 'Compare splits with other runners'},
          ]
        default:
          return 'Unknown plan'
      }
    },
  },
  name: 'plan',
  props: ['name', 'id', 'price-cents', 'current-user', 'stripe-publishable-key', 'action'],
}
</script>
