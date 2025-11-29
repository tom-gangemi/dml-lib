import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "DML Lib",
  description: "Apex DML Lib.",
  head: [['link', { rel: 'icon', href: '/favicon.ico' }]],
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Documentation', link: '/api' }
    ],

    sidebar: [
      {
        text: 'Docs',
        items: [
          { text: 'API', link: '/api' },
          { text: 'Mocking', link: '/mocking' },
          { text: 'Result', link: '/result' },
          { text: 'Examples', link: '/examples' }
        ]
      },
      {
        text: 'DMLs',
        collapsed: false,
        items: [
          { text: 'Insert', link: '/dml/insert' },
          { text: 'Update', link: '/dml/update' },
          { text: 'Upsert', link: '/dml/upsert' },
          { text: 'Delete', link: '/dml/delete' },
          { text: 'Undelete', link: '/dml/undelete' },
          { text: 'Publish', link: '/dml/publish' }
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/beyond-the-cloud-dev/dml-lib' }
    ]
  }
})
