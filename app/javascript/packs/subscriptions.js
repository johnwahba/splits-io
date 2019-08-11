/* eslint no-console: 0 */
import Vue from 'vue/dist/vue.esm'

import TurbolinksAdapter from 'vue-turbolinks'
import VueTippy from 'vue-tippy'

import subscription from '../vue/subscriptions/subscription.vue'

Vue.use(TurbolinksAdapter)
Vue.use(VueTippy)

document.addEventListener('turbolinks:load', () => {
  if (document.getElementById('vue-subscriptions') === null) {
    return
  }

  const app = new Vue({
    el: '#vue-subscriptions',
    components: { subscription },
  })
})
