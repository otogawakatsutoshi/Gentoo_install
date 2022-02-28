// @ts-check
import { Scraping } from './scraping.mjs'
import path from 'path/posix'
import winston, { format } from 'winston'

const logDir = process.env.LOG_DIR ?? './log'

const logger = winston.createLogger({
    level: 'info',
    format: format.combine(
      format.timestamp({
        format: 'YYYY-MM-DD HH:mm:ss'
      }),
      format.json()
    ),
    transports: [
      new winston.transports.Console(),
      new winston.transports.File({
        filename: path.join(logDir, 'application-.log')
      })
    ]
  })

Scraping.download('aaa', logger)
