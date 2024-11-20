import { spawn } from 'child_process';
import { getIamArn, getWhiteListIPs, getAwsRegion, confirmInfo } from './utils.js';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import chalk from 'chalk';
import ora from 'ora';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export const DeployServices = async () => {
  const userDeployInfo = {
    iamArn: await getIamArn(),
    awsRegion: await getAwsRegion(),
    whiteListIPs: await getWhiteListIPs(),
  };

  const tfvarsContent = `
iam_arn = "${userDeployInfo.iamArn}"
region = "${userDeployInfo.awsRegion}"
allowed_ips = ["${userDeployInfo.whiteListIPs}"]`;

  const terraformDir = path.join(__dirname, '../../terraform/');

  fs.writeFileSync(`${terraformDir}/terraform.tfvars`, tfvarsContent.trim());

  await confirmInfo(userDeployInfo.iamArn, userDeployInfo.awsRegion, userDeployInfo.whiteListIPs);
  
  // Function to run a command and log output in real-time
  const runCommand = (command, args, spinner) => {
    return new Promise((resolve, reject) => {
      const process = spawn(command, args, { cwd: terraformDir, stdio: 'pipe' });

      process.stdout.on('data', (data) => {
        console.log(data.toString());
      });

      process.stderr.on('data', (data) => {
        console.error(data.toString());
      });

      process.on('close', (code) => {
        spinner.stop(); // Stop the spinner when the command is done
        if (code !== 0) {
          reject(new Error(`Process exited with code ${code}`));
        } else {
          resolve();
        }
      });
    });
  };

  try {
    const initSpinner = ora('Initializing Terraform...').start();
    await runCommand('/usr/bin/terraform', ['init'], initSpinner);
    initSpinner.succeed(chalk.bold.hex('#FCE197')('Finished Terraform Init!'));

    const applySpinner = ora('Applying Terraform changes...').start();
    await runCommand('/usr/bin/terraform', ['apply', '--auto-approve'], applySpinner);
    applySpinner.succeed(chalk.bold.hex('#FCE197')('Finished Terraform Apply!'));
  } catch (error) {
    console.error('Error during Terraform execution:', error.message);
    process.exit(1);
  }

try {
  // Check the status of the resources using Terraform state
  await checkTerraformState(terraformDir, runCommand);
} catch (error) {
  console.error('Error during Terraform execution:', error.message);
  process.exit(1);
}

  return userDeployInfo;
};

const checkTerraformState = async (terraformDir, runCommand) => {
  const spinner = ora('Checking Terraform state...').start();
  
  try {
    const result = await runCommand('/usr/bin/terraform', ['show'], spinner);
    console.log('Terraform State Output:', result);
  
    // You can parse the output to check for specific resource statuses
    // For example, you might look for specific resource types or statuses in the output
    // This is a simple example; you can enhance it based on your needs
    if (result.includes('desired_count')) {
      console.log(chalk.green('Resources are in a stable state.'));
    } else {
      console.log(chalk.red('Resources may not be in a stable state.'));
    }
  } catch (error) {
    spinner.fail(chalk.bold.red('Error checking Terraform state.'));
    console.error('Error:', error.message);
  }
};