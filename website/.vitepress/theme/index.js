import DefaultTheme from 'vitepress/theme'
import BTCFooter from './components/BTCFooter.vue'
import DmlGraph from './components/DmlGraph.vue'
import './custom.css'

export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    app.component('BTCFooter', BTCFooter)
    app.component('DmlGraph', DmlGraph)
  }
}
