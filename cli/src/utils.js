import { execSync } from 'child_process';
import chalk from 'chalk';
import ora from 'ora';
import { input, select, Separator, confirm } from '@inquirer/prompts';
import { validateListOfIps } from './helpers/validation.js';

export const getIamArn = async () => {
  while (true) {
    try {
      const iamUserName = await input({ message: 'Enter your AWS IAM User Name:' });

      const iamUserInfo = execSync(
        `aws iam get-user --user-name ${iamUserName}`,
        { encoding: 'utf-8' }
      ).trim();

      return JSON.parse(iamUserInfo).User.Arn;

    } catch (error) {
      console.log(chalk.red('\nInvalid IAM User Name. Please try again.\n'));
    }
  }
};

export const getAwsRegion = async () => {
  try {
    const awsRegions = [
      { name: 'US East (N. Virginia)', value: 'us-east-1' },
      { name: 'US East (Ohio)', value: 'us-east-2' },
      { name: 'US West (N. California)', value: 'us-west-1' },
      { name: 'US West (Oregon)', value: 'us-west-2' },
      { name: 'Asia Pacific (Tokyo)', value: 'ap-northeast-1' },
      { name: 'Asia Pacific (Seoul)', value: 'ap-northeast-2' },
      { name: 'Asia Pacific (Singapore)', value: 'ap-southeast-1' },
      { name: 'Asia Pacific (Sydney)', value: 'ap-southeast-2' },
      { name: 'Europe (Frankfurt)', value: 'eu-central-1' },
      { name: 'Europe (Ireland)', value: 'eu-west-1' },
      { name: 'Europe (London)', value: 'eu-west-2' },
      { name: 'South America (São Paulo)', value: 'sa-east-1' },
    ];
    
    const awsRegion = await select({
      message: 'Select an AWS region',
      choices: awsRegions,
    });
    return awsRegion;  
  } catch (error) {
    console.log(chalk.red(`\nAn error occurred while setting your AWS region: ${error}\n`));
  }
};

export const getWhiteListIPs = async () => {
  while (true) {
    try {
      const ipList = await input({ 
        message: 'Enter single or space separated list of IPs you want to whitelist:'
      });

      const splitList = ipList.split(' ').filter(ip => ip !== '');

      if (!validateListOfIps(splitList)) {
        console.log(chalk.red('\nInvalid IP address(es) entered. Please enter valid IP address(es).\n'));
        continue;
      }

      return splitList.map(ip => `${ip}/32`);
    } catch (error) {
      console.log(chalk.red(`\nAn error occurred inputting the whitelist IP(s): ${error}\n`));
      return;
    }
  }
};

export const confirmInfo = async (arn, region, whitelist) => {
  console.log(chalk.green.bold("\nPlease Check Your Selections:\n"));
  console.log(chalk.hex('#FCE197').bold("IAM ARN: ") + chalk.green(arn));
  console.log(chalk.hex('#FCE197').bold("AWS Region: ") + chalk.green(region));
  console.log(chalk.hex('#FCE197').bold("IP Whitelist: ") + chalk.green(whitelist));
  console.log('\n');

  const confirmation = await confirm({ 
    message: 'Are these correct? Tumbleweed may not deploy with incorrect information.'});
  console.log('\n');

  if (!confirmation) {
    console.log(chalk.red('Deployment aborted, Please Try Again.'));
    process.exit(0);
  }
};


export const fetchAppIP = async () => {
  const taskSpinner = ora('Fetching Your Tumbleweed UI Public IP and URL...').start();
  try {
    const taskArnSpinner = ora('Fetching task ARN for service Tumbleweed App in ECS Tumbleweed Cluster...').start();
    const taskArn = execSync(
      `aws ecs list-tasks --cluster tumbleweed-cluster --service-name tumbleweed-app --query "taskArns[0]" --output text`,
      { encoding: 'utf-8' }
    ).trim();
    taskArnSpinner.succeed('Task ARN fetched successfully.');

    const eniSpinner = ora('Fetching Tumbleweed-App network interface ID...').start();
    const eniId = execSync(
      `aws ecs describe-tasks --cluster tumbleweed-cluster --tasks ${taskArn} --query "tasks[0].attachments[0].details[?name=='networkInterfaceId'].value" --output text`,
      { encoding: 'utf-8' }
    ).trim();
    eniSpinner.succeed('Network Interface ID fetched successfully.');

    const ipSpinner = ora('Fetching Public IP...').start();
    const publicIp = execSync(
      `aws ec2 describe-network-interfaces --network-interface-ids ${eniId} --query "NetworkInterfaces[0].Association.PublicIp" --output text`,
      { encoding: 'utf-8' }
    ).trim();
    ipSpinner.succeed('Public IP fetched successfully.');
    taskSpinner.succeed('Tumbleweed-App UI public IP fetched successfully.');
    console.log('\n');
    console.log(chalk.hex('#FCE197').bold(`Your Tumbleweed UI URL: `) +  chalk.green(`http://${publicIp}:3001`));
    console.log('\n');
  } catch (error) {
    taskSpinner.fail('Failed to fetch Tumbleweed UI IP.');
    console.log(chalk.red(`An error occurred while fetching the public IP: ${error}`));
  }
};

