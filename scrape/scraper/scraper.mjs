// @ts-check
class Scraper {
  /** @type {string} */
  topPage
  /** @type {string} */
  searchBox
  /** @type {string} */
  searchButton
  /** @type {number} */
  width
  /** @type {number} */
  height
  /** @type {string} */
  screenshotDir
  /** @type {string[]} */
  args

  /**
   * クラスYのコンストラクタの説明
   * @param {string} topPage 
   * @param {string} searchBox パラメータ２
   * @param {string} searchButton パラメータ２
   * @param {number} width パラメータ２
   * @param {number} height パラメータ２
   */
  constructor (topPage, searchBox, searchButton, width, height) {
    this.topPage = topPage
    this.searchBox = searchBox
    this.searchButton = searchButton
    this.width = width
    this.height = height
    this.screenshotDir = process.env.SCREENSHOT_DIR ?? 'screenshot'
    // docker,vagrantなどの仮想環境なら下記の設定になる。
    if (process.env.VIRTUAL_ENV) {
      this.args = [
        '--no-sandbox',
        '--disable-setuid-sandbox'
      ]
    } else {
      this.args = []
    }
  }
}

export {
  Scraper
}
