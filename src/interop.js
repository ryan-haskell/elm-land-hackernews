customElements.define("raw-html", class extends HTMLElement {
  connectedCallback() {
    this.innerHTML = '<p>' + this.rawHtml
  }
})

export const onReady = () => {
  console.log('Yes')
}