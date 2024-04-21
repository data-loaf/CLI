package terraform

import (
	"bufio"
	inputs "dataloaf/tui/inputs"
	lists "dataloaf/tui/lists"
	"fmt"
	"io"
	"io/fs"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

var terraformRoot string = "/../../terraform"

func printOutput(pipe io.Reader) {
	scanner := bufio.NewScanner(pipe)
	for scanner.Scan() {
		fmt.Println(scanner.Text())
	}
}

func addTfVar(key string, val string) string {
	var formattedKey string
	switch key {
	case "accessKey":
		formattedKey = "access_key"
	case "secretKey":
		formattedKey = "secret_key"
	case "domain":
		formattedKey = "domain_name"
	default:
		formattedKey = key
	}
	return fmt.Sprintf("-var %s='%s'", formattedKey, strings.TrimSpace(val))
}

func buildTfVars(mergedInputs inputs.InputFields, mergedList lists.Selection) []string {
	args := make([]string, 0)
	for key, val := range mergedInputs {
		args = append(args, addTfVar(key, val))
	}

	for key, val := range mergedList {
		args = append(args, addTfVar(key, val))
	}

	return args
}

func buildTfVarFiles(vars []string) []string {
	exePath, err := os.Executable()
	if err != nil {
		fmt.Println("Error: ", err)
	}

	exeDir := filepath.Dir(exePath)

	if err := os.Chdir(exeDir + terraformRoot); err != nil {
		fmt.Println("Error: ", err)
	}

	cwd, err := os.Getwd()
	if err != nil {
		fmt.Println("Error", err)
	}

	filepath.Walk(cwd, func(path string, info fs.FileInfo, err error) error {
		if err != nil {
			fmt.Println("Error:", err)
		}

		if !info.IsDir() {
			ext := filepath.Ext(path)
			if ext == ".tfvars" {
				vars = append(
					vars,
					fmt.Sprintf("-var-file='%s'", path),
				)
			}
		}

		return nil
	})

	return vars
}

func RunTerraform(mergedInputs inputs.InputFields, mergedList lists.Selection) {
	if mergedInputs["domain"] == "" {
		terraformRoot += "/http"
	} else {
		terraformRoot += "/https"
	}

	tfVars := buildTfVars(mergedInputs, mergedList)
	tfVarFiles := buildTfVarFiles(tfVars)

	tfInit := exec.Command(
		"bash",
		"-c",
		"terraform init",
	)

	if err := tfInit.Run(); err != nil {
		fmt.Println("Error: ", err)
	}

	tfApplyCmd := fmt.Sprintf(
		"terraform apply %s %s -auto-approve",
		strings.Join(tfVars, " "),
		strings.Join(tfVarFiles, " "),
	)

	tfAppy := exec.Command(
		"bash",
		"-c",
		tfApplyCmd,
	)

	stdoutPipe, _ := tfAppy.StdoutPipe()
	stderrPipe, _ := tfAppy.StderrPipe()

	if err := tfAppy.Start(); err != nil {
		fmt.Println("Error:", err)
	}

	go printOutput(stdoutPipe)
	go printOutput(stderrPipe)

	if err := tfAppy.Wait(); err != nil {
		fmt.Println("Error:", err)
		return
	}
}
