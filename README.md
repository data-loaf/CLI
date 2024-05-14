# CLI

The DataLoaf CLI is a command-line interface tool designed to simplify the deployment and management of DataLoaf infrastructure on AWS.

<details>
<summary>:warning: **Warning**</summary>

The CLI uses terraform which must be installed for it to work. Install it [here](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).
</details>

## Installation
To install DataLoaf CLI, you can clone the repository

```
git clone https://github.com/data-loaf/CLI.git
```
Once done, find the make file and make the CLI:

```
cd CLI/cmd
make dataloaf-cli
```

#### Usage:
```sh
loaf [command]
```

#### Available Commands:
- `completion`: Generate the autocompletion script for the specified shell.
- `deploy`: Deploy DataLoaf infrastructure to AWS.
- `help`: Help about any command.
- `remove`: Remove all DataLoaf infrastructure.

#### Flags:
- `-h, --help`: Display help information about the loaf command.
- `-t, --toggle`: Help message for toggle.

#### Example:
```sh
loaf deploy
```

Use "loaf [command] --help" for more information about a command.

---

### Deploy DataLoaf Infrastructure to AWS

The `deploy` command automates the provisioning of AWS infrastructure to an AWS account.

<details>
<summary>:notebook: **Note**</summary>

Must provide valid credentials to the account.
</details>

#### Usage:
```sh
loaf deploy [flags]
```

#### Flags:
- `-a, --access string`: Your AWS Access Key.
  
- `-d, --domain string`: Domain for the DataLoaf application.
  - Only required for HTTPS connections. If not provided, falls back to HTTP

- `-h, --help`: Display help information.

- `-r, --region string`: Your AWS region.

- `-s, --secret string`: Your AWS Secret Key.

#### Example:
```sh
loaf deploy -a <your_access_key> -s <your_secret_key> -r <aws_region> -d <your_domain>
```

---

### Remove All Currently Provisioned Infrastructure

The `remove` command efficiently removes all currently provisioned DataLoaf infrastructure from your AWS account, reducing unnecessary costs when infrastructure is no longer needed.

#### Usage:
```sh
loaf remove [flags]
```

#### Flags:
- `-a, --access string`: Your AWS Access Key.

- `-d, --domain string`: Domain associated with the DataLoaf application.

- `-h, --help`: Display help information.

- `-r, --region string`: Your AWS region.

- `-s, --secret string`: Your AWS Secret Key.

#### Example:
```sh
loaf remove -a <your_access_key> -s <your_secret_key> -r <aws_region> -d <your_domain>
```
