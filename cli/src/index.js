#!/usr/bin/env node

import figlet from 'figlet';
import { Command } from 'commander';
import { fetchAppIP } from './helpers/utils.js';
import { DeployServices } from './deploy.js';
import { DestroyServices } from './destroy.js';
import { TumColors } from './helpers/colors.js';
import { waitForActiveServices, waitForStableServices } from './helpers/checkState.js';

const program = new Command();

console.log(TumColors.darkYellow(figlet.textSync("Tumbleweed")));

program
  .name('Tumbleweed')
  .description('A CLI tool for deploying and destoying a Tumbleweed Pipeline')
  .version('1.0.0')
  .argument('<roll>', 'Deploy a Tumbleweed Pipeline')
  .argument('<burn>', 'Destroy a Tumbleweed Pipeline')

program
  .command('roll')
  .description('Deploying Tumbleweed Pipeline')
  .version('1.0.0')
  .action(async () => {
    try {
      const region = await DeployServices();
      await waitForActiveServices(region)
      await waitForStableServices(region);
      await fetchAppIP();
    } catch (error) {
      console.log(TumColors.darkOrange(`An error occurred while deploying services: ${error}`));
      process.exit(1);
    }
  });

program
  .command('burn')
  .description('Destroying Tumbleweed Pipeline')
  .action(async () => {
    try {
      await DestroyServices();
    } catch (error) {
      console.log(TumColors.darkOrange(`An error occurred while destroying services: ${error}`));
    }
  })

program.parse(process.argv);