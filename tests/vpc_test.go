// tests/vpc_test.go — Terratest unit tests for stratum-factory-gcp-vpc.
//
// Run locally:
//
//	cd tests && go mod tidy && go test -v -timeout 10m ./...
//
// Tests are credential-free:
//   - Positive tests use `tofu validate` (static analysis, no API calls).
//   - Negative tests use InitAndPlanE with invalid var values (variable validation
//     fires before provider auth, so no credentials are required).
package test

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// moduleDir returns the absolute path to the Factory module (repo root).
func moduleDir(t *testing.T) string {
	t.Helper()
	root, err := filepath.Abs("..")
	require.NoError(t, err, "could not resolve module path")
	return root
}

// tofuOptions returns Terratest options for the module, enforcing `tofu` binary.
func tofuOptions(t *testing.T, vars map[string]interface{}) *terraform.Options {
	t.Helper()
	return &terraform.Options{
		TerraformDir:    moduleDir(t),
		TerraformBinary: "tofu",
		Vars:            vars,
		NoColor:         true,
	}
}

// printReport emits a human-readable summary to the test log and GitHub Actions step summary.
func printReport(t *testing.T, rows [][]string) {
	t.Helper()
	header := fmt.Sprintf("%-50s %-10s %s", "Test", "Result", "Detail")
	sep := strings.Repeat("─", 90)
	t.Log("\n" + sep)
	t.Log("  STRATUM-FACTORY — GCP VPC Module Test Report")
	t.Log(sep)
	t.Log(header)
	t.Log(sep)
	for _, row := range rows {
		t.Logf("  %-50s %-10s %s", row[0], row[1], row[2])
	}
	t.Log(sep)

	if summaryFile := os.Getenv("GITHUB_STEP_SUMMARY"); summaryFile != "" {
		f, err := os.OpenFile(summaryFile, os.O_APPEND|os.O_WRONLY, 0644)
		if err != nil {
			return
		}
		defer f.Close()
		fmt.Fprintln(f, "## GCP VPC Module Test Report")
		fmt.Fprintln(f, "| Test | Result | Detail |")
		fmt.Fprintln(f, "|------|--------|--------|")
		for _, row := range rows {
			fmt.Fprintf(f, "| %s | %s | %s |\n", row[0], row[1], row[2])
		}
	}
}

// ── Positive: tofu validate (credential-free) ────────────────────────────────

// TestVpcValidate verifies that `tofu validate` succeeds for valid inputs.
func TestVpcValidate(t *testing.T) {
	t.Parallel()
	opts := tofuOptions(t, map[string]interface{}{
		"environment": "dev",
		"project_id":  "stratum-dev-sandbox",
		"name_prefix": "stratum-dev",
	})

	terraform.Init(t, opts)
	_, err := terraform.RunTerraformCommandE(t, opts, "validate")
	result, detail := "✅ PASS", "validate completed"
	if err != nil {
		result, detail = "❌ FAIL", err.Error()
	}
	printReport(t, [][]string{{"VpcValidate", result, detail}})
	require.NoError(t, err, "tofu validate must pass for valid inputs")
}

// ── Negative: variable validation blocks ─────────────────────────────────────

// TestVpcRejectsInvalidEnvironment verifies that an unapproved environment is rejected.
func TestVpcRejectsInvalidEnvironment(t *testing.T) {
	t.Parallel()
	opts := tofuOptions(t, map[string]interface{}{
		"environment": "production", // invalid — not in approved set
		"project_id":  "stratum-dev-sandbox",
		"name_prefix": "stratum-dev",
	})

	_, err := terraform.InitAndPlanE(t, opts)
	result, detail := "✅ PASS", "plan correctly rejected invalid environment"
	if err == nil {
		result, detail = "❌ FAIL", "plan should have failed for invalid environment but succeeded"
	}
	printReport(t, [][]string{{"VpcRejectsInvalidEnvironment", result, detail}})
	assert.Error(t, err, "must reject environment='production' (only dev/stage/main allowed)")
}

// TestVpcRejectsInvalidProjectId verifies that a whitespace project_id is rejected.
func TestVpcRejectsInvalidProjectId(t *testing.T) {
	t.Parallel()
	opts := tofuOptions(t, map[string]interface{}{
		"environment": "dev",
		"project_id":  "   ", // whitespace only — invalid
		"name_prefix": "stratum-dev",
	})

	_, err := terraform.InitAndPlanE(t, opts)
	result, detail := "✅ PASS", "plan correctly rejected whitespace project_id"
	if err == nil {
		result, detail = "❌ FAIL", "plan should have failed for whitespace project_id but succeeded"
	}
	printReport(t, [][]string{{"VpcRejectsInvalidProjectId", result, detail}})
	assert.Error(t, err, "must reject project_id with whitespace only")
}

// TestVpcRejectsInvalidNamePrefix verifies that a name_prefix starting with a digit is rejected.
func TestVpcRejectsInvalidNamePrefix(t *testing.T) {
	t.Parallel()
	opts := tofuOptions(t, map[string]interface{}{
		"environment": "dev",
		"project_id":  "stratum-dev-sandbox",
		"name_prefix": "1bad", // starts with digit — invalid
	})

	_, err := terraform.InitAndPlanE(t, opts)
	result, detail := "✅ PASS", "plan correctly rejected name_prefix starting with digit"
	if err == nil {
		result, detail = "❌ FAIL", "plan should have failed for name_prefix='1bad' but succeeded"
	}
	printReport(t, [][]string{{"VpcRejectsInvalidNamePrefix", result, detail}})
	assert.Error(t, err, "must reject name_prefix starting with a digit")
}

// TestVpcRejectsInvalidRoutingMode verifies that an invalid routing_mode is rejected.
func TestVpcRejectsInvalidRoutingMode(t *testing.T) {
	t.Parallel()
	opts := tofuOptions(t, map[string]interface{}{
		"environment":  "dev",
		"project_id":   "stratum-dev-sandbox",
		"name_prefix":  "stratum-dev",
		"routing_mode": "INVALID",
	})

	_, err := terraform.InitAndPlanE(t, opts)
	result, detail := "✅ PASS", "plan correctly rejected invalid routing_mode"
	if err == nil {
		result, detail = "❌ FAIL", "plan should have failed for routing_mode='INVALID' but succeeded"
	}
	printReport(t, [][]string{{"VpcRejectsInvalidRoutingMode", result, detail}})
	assert.Error(t, err, "must reject routing_mode='INVALID'")
}

// ── OpenTofu binary enforcement ───────────────────────────────────────────────

// TestNoTerraformBinary verifies that no .tf file references the `terraform` binary.
func TestNoTerraformBinary(t *testing.T) {
	t.Parallel()
	tfFiles, _ := filepath.Glob("../*.tf")
	issues := []string{}
	for _, f := range tfFiles {
		content, err := os.ReadFile(f)
		require.NoError(t, err)
		lines := strings.Split(string(content), "\n")
		for i, line := range lines {
			trimmed := strings.TrimSpace(line)
			if strings.Contains(trimmed, "terraform") &&
				!strings.HasPrefix(trimmed, "#") &&
				!strings.HasPrefix(trimmed, "//") &&
				trimmed != "terraform {" &&
				!strings.HasPrefix(trimmed, "required_version") &&
				!strings.HasPrefix(trimmed, "required_providers") &&
				!strings.HasPrefix(trimmed, "backend") &&
				!strings.Contains(trimmed, "TerraformBinary") {
				if strings.Contains(trimmed, "\"terraform\"") || strings.Contains(trimmed, "`terraform`") {
					issues = append(issues, fmt.Sprintf("%s:%d: %s", f, i+1, trimmed))
				}
			}
		}
	}
	result, detail := "✅ PASS", "no terraform binary references found in .tf files"
	if len(issues) > 0 {
		result = "❌ FAIL"
		detail = fmt.Sprintf("terraform binary references found: %v", issues)
	}
	printReport(t, [][]string{{"NoTerraformBinary", result, detail}})
	assert.Empty(t, issues, "no .tf file should reference the 'terraform' binary (use 'tofu')")
}
