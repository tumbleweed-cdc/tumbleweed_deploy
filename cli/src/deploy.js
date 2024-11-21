import { spawn } from 'child_process';
import { getIamArn, getWhiteListIPs, getAwsRegion, confirmInfo } from './helpers/utils.js';
import { getTerraformPath } from './helpers/terminal.js'
import { TumColors } from './helpers/colors.js';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import ora from 'ora';

export const DeployServices = async () => {
  const userDeployInfo = {
    iamArn: await getIamArn(),
    awsRegion: await getAwsRegion(),
    whiteListIPs: await getWhiteListIPs(),
  };

  await confirmInfo(userDeployInfo.iamArn, userDeployInfo.awsRegion, userDeployInfo.whiteListIPs);

  const __filename = fileURLToPath(import.meta.url);
  const __dirname = path.dirname(__filename);
  const terraformPath = await getTerraformPath();

  const tfvarsContent = `
iam_arn = "${userDeployInfo.iamArn}"
region = "${userDeployInfo.awsRegion}"
allowed_ips = [${userDeployInfo.whiteListIPs.map(ip => `"${ip}"`).join(", ")}]`;

  const terraformDir = path.join(__dirname, '../terraform/');

  fs.writeFileSync(`${terraformDir}/terraform.tfvars`, tfvarsContent.trim());

  const runCommand = (command, args, spinner) => {
    return new Promise((resolve, reject) => {
      const process = spawn(command, args, { cwd: terraformDir, stdio: 'pipe' });

      process.stdout.on('data', (data) => {
        console.log(TumColors.lightBrown(data.toString()));
      });

      process.stderr.on('data', (data) => {
        console.error(TumColors.darkOrange(data.toString()));
      });

      process.on('close', (code) => {
        if (code !== 0) {
          spinner.fail(TumColors.darkOrange('✖'));
          reject(new Error(`Process exited with code ${code}`));
      } else {
          resolve();
      }
      });
    });
  };

  try {
    const initSpinner = ora(TumColors.lightYellow.bold('Rolling Terraform initialization...')).start();
    await runCommand(terraformPath, ['init'], initSpinner);
    initSpinner.succeed(TumColors.lightYellow.bold('Finished init roll!'));

    const applySpinner = ora(TumColors.lightYellow.bold('Rolling Terraform application...')).start();
    await runCommand(terraformPath, ['apply', '--auto-approve'], applySpinner);
    applySpinner.succeed(TumColors.lightYellow.bold('Finished apply roll!'));
  } catch (error) {
    console.error(TumColors.darkOrange('Error during Tumbleweed roll:', error.message));
    process.exit(1);
  }

  return userDeployInfo.awsRegion;
};