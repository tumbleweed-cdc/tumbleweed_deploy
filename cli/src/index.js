#!/usr/bin/env node

import chalk from 'chalk';
import figlet from 'figlet';
import { Command } from 'commander';
import ora from 'ora';
import { fetchAppIP } from './utils.js';
import { DeployServices } from './deploy.js';

const program = new Command();

console.log(chalk.hex('#FCE197')(figlet.textSync("Tumbleweed")));

program
  .name('get-public-ip')
  .description('Deploying Tumbleweed App Service')
  .version('1.0.0')
  .action(async () => {
    try {
      await DeployServices();
      await fetchAppIP();
    } catch (error) {
      console.log(chalk.red(`An error occurred while deploying the services: ${error}`));
    }
  });


program.parse(process.argv);

// const options = program.opts();

// if (!process.argv.slice(2).length) {
//   program.outputHelp();
// }