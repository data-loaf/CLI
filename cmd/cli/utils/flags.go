package utils

import (
	inputs "dataloaf/tui/inputs"
	lists "dataloaf/tui/lists"

	"github.com/spf13/cobra"
)

func mergeFlagsAndInputs(
	inputFlags inputs.InputFields,
	inputResults inputs.InputFields,
) inputs.InputFields {
	mergedInputs := make(map[string]string)

	for key, value := range inputFlags {
		mergedInputs[key] = value
	}

	for key, value := range inputResults {
		mergedInputs[key] = value
	}

	return mergedInputs
}

func mergeFlagsAndListSelection(
	listFlag string,
	selection lists.Selection,
) lists.Selection {
	if len(listFlag) > 0 {
		selection["ami"] = lists.AmiMap[listFlag]
		return selection
	}

	return selection
}

type flags struct {
	Inputs inputs.InputFields
	List   string
}

func allFlags(cmd *cobra.Command) flags {
	accessKey, _ := cmd.Flags().GetString("access")
	secretKey, _ := cmd.Flags().GetString("secret")
	domain, _ := cmd.Flags().GetString("domain")
	region, _ := cmd.Flags().GetString("region")

	inputFlags := inputs.InputFields{
		"accessKey": accessKey,
		"secretKey": secretKey,
		"domain":    domain,
	}

	var listFlag string = region
	return flags{inputFlags, listFlag}
}
