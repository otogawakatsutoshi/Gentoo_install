// @ts-check
import puppeteer from 'puppeteer'

/**
 * puppeteer の初期化を行う。
 * @returns {Promise<puppeteer.Page>}
 */
async function launch () {
  const browser = await puppeteer.launch({
    // docker 内では下の様にする。
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox'
    ]
  })
  return await browser.newPage()
}

export {
  launch
}

// /**
//  * 検索窓から指定の言葉を検索します。
//  * @param searchWord 検索に使う文字列です。
//  * @param logger winstonのloggerを渡してください。これを使ってログを吐きます。
//  */
// async function search (searchWord: string, logger: winston.Logger) {
//   const browser = await puppeteer.launch({
//     // docker 内では下の様にする。
//     args: [
//       '--no-sandbox',
//       '--disable-setuid-sandbox'
//     ]
//   })
//   const page = await browser.newPage()
//   await page.goto(topPage)
//   await page.setViewport({ width: 1219, height: 757 })

//   await page.waitForSelector(searchBox)
//   await page.type(searchBox, searchWord)
//   await page.waitForSelector(searchButton)
//   await page.click(searchButton)
//   await page.waitForTimeout(5000)
//   //  await page.waitForNavigation()
//   const screenshotDir = process.env.SCREENSHOT_DIR ?? 'screenshot'

//   await page.screenshot({ path: path.join(screenshotDir, 'example.png'), fullPage: true })
//   // await navigationPromise

//   await browser.close()
// }

// const Scraping = {
//   search: search
// }
// export {
//   Scraping
// }
