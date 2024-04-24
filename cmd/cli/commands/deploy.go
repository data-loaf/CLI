package commands

import (
	utils "dataloaf/cli/utils"

	"github.com/spf13/cobra"
)

func executeDeploy(cmd *cobra.Command, args []string) {
	utils.ExecuteCmd(cmd, args)
}

var DeployCmd = &cobra.Command{
	Use:   "deploy",
	Short: "Deploy DataLoaf infrastructure to AWS (powered by terraform)",
	Long:  ``,
	Run:   executeDeploy,
}

func init() {
	DeployCmd.Flags().StringP("access", "a", "", "Your AWS Access Key")
	DeployCmd.Flags().StringP("secret", "s", "", "Your AWS Secret Key")
	DeployCmd.Flags().StringP("region", "r", "", "Your AWS region")
	DeployCmd.Flags().StringP("domain", "d", "", "Domain you want to use for DataLoaf app")
}
