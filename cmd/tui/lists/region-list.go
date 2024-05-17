package lists

import (
	"github.com/charmbracelet/bubbles/list"
)

var Regions = []list.Item{
	item{title: "us-east-1", desc: "US East (N. Virginia)"},
	item{title: "us-east-2", desc: "US East (Ohio)"},
	item{title: "us-west-1", desc: "US West (N. California)"},
	item{title: "us-west-2", desc: "US West (Oregon)"},
	item{title: "ap-south-1", desc: "Asia Pacific (Mumbai)"},
	item{title: "ap-northeast-1", desc: "Asia Pacific (Tokyo)"},
	item{title: "ap-northeast-2", desc: "Asia Pacific (Seoul)"},
	item{title: "ap-southeast-1", desc: "Asia Pacific (Singapore)"},
	item{title: "ap-southeast-2", desc: "Asia Pacific (Sydney)"},
	item{title: "ca-central-1", desc: "Canada (Central)"},
	item{title: "eu-central-1", desc: "Europe (Frankfurt)"},
	item{title: "eu-west-1", desc: "Europe (Ireland)"},
	item{title: "eu-west-2", desc: "Europe (London)"},
	item{title: "eu-west-3", desc: "Europe (Paris)"},
	item{title: "eu-north-1", desc: "Europe (Stockholm)"},
	item{title: "sa-east-1", desc: "South America (São Paulo)"},
}
