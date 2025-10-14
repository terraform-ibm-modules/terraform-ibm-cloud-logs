// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"fmt"
	"log"
	"math/rand"
	"os"
	"strings"
	"testing"

	"github.com/IBM/go-sdk-core/v5/core"
	"github.com/gruntwork-io/terratest/modules/files"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testaddons"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

/*
Global variables
*/

const resourceGroup = "geretain-test-resources"
const configurableDADir = "solutions/fully-configurable"
const secureDADir = "solutions/security-enforced"
const terraformVersion = "terraform_v1.10" // This should match the version in the ibm_catalog.json
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

var permanentResources map[string]interface{}
var validRegions = []string{
	"au-syd",
	"eu-de",
	"eu-es",
	"eu-gb",
	"us-south",
}

// TestMain will be run before any parallel tests, used to read data from yaml for use with tests
func TestMain(m *testing.M) {

	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(m.Run())
}

func TestSecurityEnforced(t *testing.T) {
	t.Parallel()

	var region = validRegions[rand.Intn(len(validRegions))]
	prefix := fmt.Sprintf("iclda-sec-%s", strings.ToLower(random.UniqueId()))

	// ------------------------------------------------------------------------------------
	// Provision COS and EN first
	// ------------------------------------------------------------------------------------

	var preReqDir = "./resources/prereq-cos-and-en"
	realTerraformDir := preReqDir
	tempTerraformDir, _ := files.CopyTerraformFolderToTemp(realTerraformDir, fmt.Sprintf(prefix+"-%s", strings.ToLower(random.UniqueId())))
	tags := common.GetTagsFromTravis()

	// Verify ibmcloud_api_key variable is set
	checkVariable := "TF_VAR_ibmcloud_api_key"
	val, present := os.LookupEnv(checkVariable)
	require.True(t, present, checkVariable+" environment variable not set")
	require.NotEqual(t, "", val, checkVariable+" environment variable is empty")

	logger.Log(t, "Tempdir: ", tempTerraformDir)
	existingTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: tempTerraformDir,
		Vars: map[string]interface{}{
			"prefix":        prefix,
			"region":        region,
			"resource_tags": tags,
		},
		// Set Upgrade to true to ensure latest version of providers and modules are used by terratest.
		// This is the same as setting the -upgrade=true flag with terraform.
		Upgrade: true,
	})
	terraform.WorkspaceSelectOrNew(t, existingTerraformOptions, prefix)
	_, existErr := terraform.InitAndApplyE(t, existingTerraformOptions)
	if existErr != nil {
		assert.True(t, existErr == nil, "Init and Apply of pre-req resources failed in TestRunFullyConfigurable test")
	} else {
		// ------------------------------------------------------------------------------------
		// Deploy DA
		// ------------------------------------------------------------------------------------

		options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
			Testing: t,
			Region:  region,
			Prefix:  prefix,
			TarIncludePatterns: []string{
				"*.tf",
				"modules/logs_policy" + "/*.tf",
				"modules/webhook" + "/*.tf",
				secureDADir + "/*.tf",
				configurableDADir + "/*.tf",
			},
			ResourceGroup:          resourceGroup,
			TemplateFolder:         secureDADir,
			Tags:                   []string{"test-schematic", "icl-da-se"},
			DeleteWorkspaceOnFail:  false,
			WaitJobCompleteMinutes: 60,
			TerraformVersion:       terraformVersion,
		})

		options.TerraformVars = []testschematic.TestSchematicTerraformVar{
			{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
			{Name: "existing_resource_group_name", Value: terraform.Output(t, existingTerraformOptions, "resource_group_name"), DataType: "string"},
			{Name: "region", Value: region, DataType: "string"},
			{Name: "prefix", Value: prefix, DataType: "string"},
			{Name: "cloud_logs_resource_tags", Value: options.Tags, DataType: "list(string)"},
			{Name: "cloud_logs_access_tags", Value: permanentResources["accessTags"], DataType: "list(string)"},
			{Name: "existing_cos_instance_crn", Value: terraform.Output(t, existingTerraformOptions, "cos_crn"), DataType: "string"},
			{Name: "existing_kms_instance_crn", Value: permanentResources["hpcs_south_crn"], DataType: "string"},
			{Name: "existing_event_notifications_instances", Value: terraform.OutputJson(t, existingTerraformOptions, "en_crns"), DataType: "list(object)"},
		}

		err := options.RunSchematicTest()
		assert.Nil(t, err, "This should not have errored")

	}

	// Check if "DO_NOT_DESTROY_ON_FAILURE" is set
	envVal, _ := os.LookupEnv("DO_NOT_DESTROY_ON_FAILURE")
	// Destroy the temporary existing resources if required
	if t.Failed() && strings.ToLower(envVal) == "true" {
		fmt.Println("Terratest failed. Debug the test and delete resources manually.")
	} else {
		logger.Log(t, "START: Destroy (prereq resources)")
		terraform.Destroy(t, existingTerraformOptions)
		terraform.WorkspaceDelete(t, existingTerraformOptions, prefix)
		logger.Log(t, "END: Destroy (prereq resources)")
	}
}

func TestUpgradeSecurityEnforced(t *testing.T) {
	t.Parallel()

	var region = validRegions[rand.Intn(len(validRegions))]
	prefix := fmt.Sprintf("iclda-up-%s", strings.ToLower(random.UniqueId()))

	// ------------------------------------------------------------------------------------
	// Provision COS and EN first
	// ------------------------------------------------------------------------------------

	var preReqDir = "./resources/prereq-cos-and-en"
	realTerraformDir := preReqDir
	tempTerraformDir, _ := files.CopyTerraformFolderToTemp(realTerraformDir, fmt.Sprintf(prefix+"-%s", strings.ToLower(random.UniqueId())))
	tags := common.GetTagsFromTravis()

	// Verify ibmcloud_api_key variable is set
	checkVariable := "TF_VAR_ibmcloud_api_key"
	val, present := os.LookupEnv(checkVariable)
	require.True(t, present, checkVariable+" environment variable not set")
	require.NotEqual(t, "", val, checkVariable+" environment variable is empty")

	logger.Log(t, "Tempdir: ", tempTerraformDir)
	existingTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: tempTerraformDir,
		Vars: map[string]interface{}{
			"prefix":        prefix,
			"region":        region,
			"resource_tags": tags,
		},
		// Set Upgrade to true to ensure latest version of providers and modules are used by terratest.
		// This is the same as setting the -upgrade=true flag with terraform.
		Upgrade: true,
	})
	terraform.WorkspaceSelectOrNew(t, existingTerraformOptions, prefix)
	_, existErr := terraform.InitAndApplyE(t, existingTerraformOptions)
	if existErr != nil {
		assert.True(t, existErr == nil, "Init and Apply of pre-req resources failed in TestRunFullyConfigurable test")
	} else {
		// ------------------------------------------------------------------------------------
		// Deploy DA
		// ------------------------------------------------------------------------------------

		options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
			Testing: t,
			Region:  region,
			Prefix:  prefix,
			TarIncludePatterns: []string{
				"*.tf",
				"modules/logs_policy" + "/*.tf",
				"modules/webhook" + "/*.tf",
				secureDADir + "/*.tf",
				configurableDADir + "/*.tf",
			},
			ResourceGroup:              resourceGroup,
			TemplateFolder:             secureDADir,
			Tags:                       []string{"test-schematic", "icl-da-se-upg"},
			DeleteWorkspaceOnFail:      false,
			WaitJobCompleteMinutes:     60,
			TerraformVersion:           terraformVersion,
			CheckApplyResultForUpgrade: true,
		})

		options.TerraformVars = []testschematic.TestSchematicTerraformVar{
			{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
			{Name: "existing_resource_group_name", Value: terraform.Output(t, existingTerraformOptions, "resource_group_name"), DataType: "string"},
			{Name: "region", Value: region, DataType: "string"},
			{Name: "prefix", Value: prefix, DataType: "string"},
			{Name: "cloud_logs_resource_tags", Value: options.Tags, DataType: "list(string)"},
			{Name: "cloud_logs_access_tags", Value: permanentResources["accessTags"], DataType: "list(string)"},
			{Name: "existing_cos_instance_crn", Value: terraform.Output(t, existingTerraformOptions, "cos_crn"), DataType: "string"},
			{Name: "existing_kms_instance_crn", Value: permanentResources["hpcs_south_crn"], DataType: "string"},
			{Name: "existing_event_notifications_instances", Value: terraform.OutputJson(t, existingTerraformOptions, "en_crns"), DataType: "list(object)"},
		}

		err := options.RunSchematicUpgradeTest()
		if !options.UpgradeTestSkipped {
			assert.Nil(t, err, "This should not have errored")
		}

	}

	// Check if "DO_NOT_DESTROY_ON_FAILURE" is set
	envVal, _ := os.LookupEnv("DO_NOT_DESTROY_ON_FAILURE")
	// Destroy the temporary existing resources if required
	if t.Failed() && strings.ToLower(envVal) == "true" {
		fmt.Println("Terratest failed. Debug the test and delete resources manually.")
	} else {
		logger.Log(t, "START: Destroy (prereq resources)")
		terraform.Destroy(t, existingTerraformOptions)
		terraform.WorkspaceDelete(t, existingTerraformOptions, prefix)
		logger.Log(t, "END: Destroy (prereq resources)")
	}
}

// Test deployment with all "on-by-default" dependant DAs
func TestAddonDefaultConfiguration(t *testing.T) {
	t.Parallel()

	options := testaddons.TestAddonsOptionsDefault(&testaddons.TestAddonOptions{
		Testing:       t,
		Prefix:        "icl-def",
		ResourceGroup: resourceGroup,
		QuietMode:     true, // Suppress logs except on failure
	})

	options.AddonConfig = cloudinfo.NewAddonConfigTerraform(
		options.Prefix,
		"deploy-arch-ibm-cloud-logs",
		"fully-configurable",
		map[string]interface{}{
			"prefix":                  options.Prefix,
			"region":                  validRegions[rand.Intn(len(validRegions))],
			"existing_resource_group": resourceGroup,
		},
	)

	// Disable target / route creation to prevent hitting quota in account
	options.AddonConfig.Dependencies = []cloudinfo.AddonConfig{
		{
			OfferingName:   "deploy-arch-ibm-cloud-monitoring",
			OfferingFlavor: "fully-configurable",
			Inputs: map[string]interface{}{
				"enable_metrics_routing_to_cloud_monitoring": false,
			},
			Enabled: core.BoolPtr(true),
		},
	}

	err := options.RunAddonTest()
	require.NoError(t, err)
}
