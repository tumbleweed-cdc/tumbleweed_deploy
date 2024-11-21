import { spawn } from 'child_process';
import { confirm } from '@inquirer/prompts';
import { getTerraformPath } from './helpers/terminal.js'
import { TumColors } from './helpers/colors.js';
import path from 'path';
import { fileURLToPath } from 'url';
import ora from 'ora';


export const DestroyServices = async () => {
  const __filename = fileURLToPath(import.meta.url);
  const __dirname = path.dirname(__filename);
  const terraformPath = await getTerraformPath();
  const terraformDir = path.join(__dirname, '../terraform/');

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
    const confirmation = await confirm({ 
      message: 'Are you sure you want to proceed with the incineration of your Tumbleweed pipeline?'});
    console.log('\n');
  
    if (!confirmation) {
      console.log(TumColors.darkOrange('Burn aborted!'));
      process.exit(0);
    }
    const destroySpinner = ora(TumColors.lightYellow.bold('Burning Tumbleweed Down...')).start();
    await runCommand(terraformPath, ['destroy', '--auto-approve'], destroySpinner);
    destroySpinner.succeed(TumColors.lightYellow.bold('Finished Terraform Destroy!'));
    console.log(TumColors.lightYellow.bold('Tumbleweed has been burned to the ground!'));
  } catch (error) {
    console.error(TumColors.darkOrange('Error during Tumbleweed incineration:', error.message));
    process.exit(1);
  }
};

