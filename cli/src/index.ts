import axios from 'axios';
import chalk from 'chalk';
import clear from 'clear';
import figlet from 'figlet';
import { Command } from 'commander';

// chalk.level = 3;
const program = new Command();

console.log(chalk.yellow(figlet.textSync("Tumbleweed")));

program
  .version("Version 1.0.0")
  .description("A CLI For setting up your Tumbleweed deployment")
  .option("-l, --ls  [value]", "List directory contents")
  .option("-m, --mkdir <value>", "Create a directory")
  .option("-t, --touch <value>", "Create a file")
  .parse(process.argv);

const options = program.opts();

if (!process.argv.slice(2).length) {
  program.outputHelp();
}