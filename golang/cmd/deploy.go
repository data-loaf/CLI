package cmd

import (
	"github.com/spf13/cobra"
)

func getAccessKey() {}

func getSecretKey() {}

func getRegion() {}

func executeDeploy(cmd *cobra.Command, args []string) {
	accessKey, _ := cmd.Flags().GetString("access")
	secretKey, _ := cmd.Flags().GetString("secret")
	region, _ := cmd.Flags().GetString("region")

	if accessKey == "" {
		getAccessKey()
	}

	if secretKey == "" {
		getSecretKey()
	}

	if region == "" {
		getRegion()
	}
}

// deployCmd represents the deploy command
var deployCmd = &cobra.Command{
	Use:   "deploy",
	Short: "Deploy your infrastructure to AWS (powered by terraform)",
	Long:  ``,
	Run:   executeDeploy,
}

func init() {
	rootCmd.AddCommand(deployCmd)
	deployCmd.Flags().StringP("access", "a", "", "Your AWS Access Key")
	deployCmd.Flags().StringP("secret", "s", "", "Your AWS Secret Key")
	deployCmd.Flags().StringP("region", "r", "", "Your AWS region")
}
