// @ts-check

import path from 'path'
import fs from 'fs'
import util from 'util'
import fetch from "node-fetch";
const writeFilePromise = util.promisify(fs.writeFile);
import puppeteer from 'puppeteer'
import winston from 'winston'
import { Scraper } from './scraper/index.mjs'

// /html/body/div[5]/div/ul/li[2]/a
// https://www.dlsite.com/
// const topPage = 'https://www.dlsite.com/maniax/'
// const searchBox = '//*[@id="twotabsearchtextbox"]'
// const searchButton = '//*[@id="nav-search-submit-button"]'
const scraper = new Scraper(
  'https://www.gentoo.org/downloads/',
  '#twotabsearchtextbox',
  '#nav-search-submit-button',
  1219,
  757
)

/**
 * 特定のファイルをダウンロードシアm巣。
 * @param {string} searchWord 検索に使う文字列です。
 * @param {winston.Logger} logger winstonのloggerを渡してください。これを使ってログを吐きます。
 */
async function download (searchWord, logger) {
  const browser = await puppeteer.launch({
    // docker 内では下の様にする。
    args: scraper.args
  })
  const page = await browser.newPage()
  await page.goto(scraper.topPage)
  await page.setViewport({ width: scraper.width, height: scraper.height })

  await console.log('start download gentoo minimal install.iso');
  // await page.waitForSelector('#content > div:nth-child(3) > div:nth-child(1) > div > div > div:nth-child(3) > a')
  // await page.click('#content > div:nth-child(3) > div:nth-child(1) > div > div > div:nth-child(3) > a')

  await console.log('start download gentoo stage3-systemd');
  // await page.waitForSelector('#content > div:nth-child(3) > div:nth-child(1) > div > div > div:nth-child(5) > a:nth-child(2)')
  // await page.click('#content > div:nth-child(3) > div:nth-child(1) > div > div > div:nth-child(5) > a:nth-child(2)')

  await console.log('start download gentoo stage3-desktop-systemd');
  await page.waitForSelector('#content > div:nth-child(3) > div:nth-child(1) > div > div > div:nth-child(5) > a:nth-child(4)');
  // await page.click('#content > div:nth-child(3) > div:nth-child(1) > div > div > div:nth-child(5) > a:nth-child(4)');

  const itemSelector="#content > div:nth-child(3) > div:nth-child(1) > div > div > div:nth-child(5) > a:nth-child(4)";

  const item = await page.$(itemSelector);
  /** @type {string} */
  const url = await (await item.getProperty('href')).jsonValue();

  await fetch(url)
    .then(x => x.arrayBuffer())
    .then(
      x => util.promisify(fs.writeFile)('./', Buffer.from(x))
    );

  // function downloadFile(url, outputPath) {
  //   return fetch(url)
  //       .then(x => x.arrayBuffer())
  //       .then(x => writeFilePromise(outputPath, Buffer.from(x)));
  // }

  // const downloadFile = await (async (url, path) => {
  //   const res = await fetch(url);
  //   const fileStream = fs.createWriteStream(path);
  //   await new Promise((resolve, reject) => {
  //       res.body.pipe(fileStream);
  //       res.body.on("error", reject);
  //       fileStream.on("finish", resolve);
  //     });
  // })(url,'');

  await console.log(url);

  await console.log('finish download gentoo stage3-desktop-systemd');
  await page.waitForTimeout(5000 * 365);

  await page.screenshot({ path: path.join(scraper.screenshotDir, 'example.png'), fullPage: true });

  // minimal install
  
  //*[@id="content"]/div[1]/div[1]/div/div/div[1]/a
  
  

  

  // gentoo stage3
  //*[@id="content"]/div[1]/div[1]/div/div/div[2]/a[2]

  // gentoo stage3
  //*[@id="content"]/div[1]/div[1]/div/div/div[2]/a[4]

  await browser.close();
}

/**
 * 検索窓から指定の言葉を検索します。
 * @param {string} searchWord 検索に使う文字列です。
 * @param {winston.Logger} logger winstonのloggerを渡してください。これを使ってログを吐きます。
 */
async function search (searchWord, logger) {
  const browser = await puppeteer.launch({
    // docker 内では下の様にする。
    args: scraper.args
  })
  const page = await browser.newPage()
  await page.goto(scraper.topPage)
  await page.setViewport({ width: scraper.width, height: scraper.height })

  await page.waitForSelector(scraper.searchBox)
  await page.type(scraper.searchBox, searchWord)
  await page.waitForSelector(scraper.searchButton)
  await page.click(scraper.searchButton)
  await page.waitForTimeout(5000)

  await page.screenshot({ path: path.join(scraper.screenshotDir, 'example.png'), fullPage: true })

  // minimal install
  
  //*[@id="content"]/div[1]/div[1]/div/div/div[1]/a
  // gentoo stage3
  //*[@id="content"]/div[1]/div[1]/div/div/div[2]/a[2]

  // gentoo stage3
  //*[@id="content"]/div[1]/div[1]/div/div/div[2]/a[4]

  const target = await page.$$('#search > div.s-desktop-width-max.s-desktop-content.s-opposite-dir.sg-row > div.s-matching-dir.sg-col-16-of-20.sg-col.sg-col-8-of-12.sg-col-12-of-16 > div > span:nth-child(4) > div.s-main-slot.s-result-list.s-search-results.sg-row')

  await target.forEach(
    /** */
    (value, index, array) => {
      logger.info(value)
    })

  await browser.close()
}

const Scraping = {
  search: search,
  download: download,
}
export {
  Scraping
}
