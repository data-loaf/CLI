package commands

import (
	utils "dataloaf/cli/utils"

	"github.com/spf13/cobra"
)

func executeRemove(cmd *cobra.Command, args []string) {
	utils.ExecuteCmd(cmd, args)
}

var RemoveCmd = &cobra.Command{
	Use:   "remove",
	Short: "Remove all DataLoaf infrastructure",
	Long:  `Remove all currently provisioned DataLoaf infrastructure from AWS`,
	Run:   executeRemove,
}

func init() {
	RemoveCmd.Flags().StringP("access", "a", "", "Your AWS Access Key")
	RemoveCmd.Flags().StringP("secret", "s", "", "Your AWS Secret Key")
	RemoveCmd.Flags().StringP("region", "r", "", "Your AWS region")
	RemoveCmd.Flags().StringP("domain", "d", "", "Domain you want to use for DataLoaf app")
}
