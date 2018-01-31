---
layout: article
title: CLI 2.0 JMESPATH
date: 2017-10-04
tags: [cli, bash]
comments: true
author: Richard_Cheney
image:
  teaser: blueprint.png
previous:
  url: ../cli-2-firststeps
  title: First Steps with CLI 2.0
next:
  url: ../cli-4-bash
  title: Using CLI 2.0 within Bash
---
{% include toc.html %}

## Introduction 

The `--query` switch is one of the "global" switches, i.e. it is available on every az command, and it enables you to query and filter the output of the command.  

The Azure CLI uses the industry standard JMESPATH query format that is used not only by the CLI, but also the AWS CLI and other commands that need to manipulate JSON. 

There is some excellent documentation on JMESPATH at the official site, and it covers the full range of what can be accomplished.  This guide will give you a shortcut into the commonly used functionality when querying Azure JSON output.  

## JSON Format

Here is some example JSON output from an `az resource list --resource-group <resourceGroup> --output json` command.  The example resource group below(myAppRG-Staging) contains a single Web App in standard app service plan.

```json
[
  {
    "id": "/subscriptions/2ca40be1-7680-4f2b-92f7-06b2123a68cc/resourceGroups/myAppRG-Staging/providers/Microsoft.Web/serverFarms/MyAppServicePlan",
    "identity": null,
    "kind": "app",
    "location": "westeurope",
    "managedBy": null,
    "name": "MyAppServicePlan",
    "plan": null,
    "properties": null,
    "resourceGroup": "myAppRG-Staging",
    "sku": null,
    "tags": {
      "displayName": "myAppServicePlan"
    },
    "type": "Microsoft.Web/serverFarms"
  },
  {
    "id": "/subscriptions/2ca40be1-7680-4f2b-92f7-06b2123a68cc/resourceGroups/myAppRG-Staging/providers/Microsoft.Web/sites/MyWebApp-richeney-Staging",
    "identity": null,
    "kind": "app",
    "location": "westeurope",
    "managedBy": null,
    "name": "MyWebApp-richeney-Staging",
    "plan": null,
    "properties": null,
    "resourceGroup": "myAppRG-Staging",
    "sku": null,
    "tags": {
      "displayName": "myWebApp",
      "hidden-related:/subscriptions/2ca40be1-7e80-4f2b-92f7-06b2123a68cc/resourceGroups/myAppRG-Staging/providers/Microsoft.Web/serverfarms/MyAppServicePlan": "Resource"
    },
    "type": "Microsoft.Web/sites"
  }
]
```

Whilst it may initially look complex, there are only keys, values, and structures.

The structures are split into two types:

1. Arrays, denoted by square brackets
   * Arrays in JSON are ordered lists of value
   * Also known as lists or vectors
   * In Azure that order depends on the context.  It may be based on order, such as with VM NICs, or alphabetically by name, i.e. when listing resource groups
2. Objects, denoted by curly brackets
   * Objects are collections of name:value pairs
   * Also known as keyed lists, dictionaries or hashes 

When arrays and objects contain multiple elements then those elements are separated by commas.

Values may be:
* string
* number
* true
* false
* null
* object
* array

JSON also supports nested objects and arrays nicely.  The elements of a list may simply be unkeyed values (e.g. ['red', 'white', 'blue']), or it may be another structure, i.e. a nested array or object.  You can see this in the example above.

Note that JSON files do not need to be indented to preserve the structure in the way that a YAML file or a Python script do.  However if it is likely to be read by humans then it is common practice to indent the output to reflect the nested levels.  This is also known as pretty printing.  

## Selecting Array Elements

Rather than reporting a whole array, it is possible to pull out a subset.

Each of the commands below follow `az resource list --resource-group myAppRG-Staging --query '<query>' --output json` format.  Only the query switch will be shown in the table below for the sake of brevity. 

**Query** | **Output**
`--query '[*]'` | Pass through the whole array
`--query '[]'` | Flatten the array
`--query '[0]'` | First entity 
`--query '[-1]'` | Last entity
`--query '[a:b]'` | Array slice from a to b-1

If you omit either the a or b value from a slice then the slice array goes to the start or end, e.g. `'[:2]'` gives the first two elements (i.e. 0 and 1), whereas `'[2:]'` will give all remaining elements from a list, from element 2 onwards.

Compare `'[0]'` and `'[:1]'` to see a subtle difference.  The former is the object that is the first array element, and therefore starts with curly brackets, whereas the second is an array slice, containing only that same first element, i.e. it still has square brackets surrounding it. 

You can also step through an array using the `'[a:b:c]'` notation, but there are few valid reasons where that makes sense in Azure.  Perhaps in slicing the odd and even NICs for a VM with multiple NICs. One additional use is to reverse an array using `'[::-1]'`.   

You can also slice based on querying the data - see below.

You'll initially see little difference in the `'[*]'` and `'[]'` queries, but array flattening will make more sense when we shift to filtering at deeper levels.

## Selecting Object Values

You can also be selective on the name:value objects. 

Querying on the name for a name:value pair is trivial and simply state the name.  Use the `az account show --query '<query>' --output json` command to show your active Azure subscription.

**Query** | **Output**
`--query 'name'` | Cosmetic name for the subscription
`--query 'id'` | The ID for the subscription
`--query 'user'` | The user **object** for the subscription
`--query 'user.name'` | The value for name within the user object

The last example above shows a nested value, pulling the value of name in the user object.

When pulling out individual values, the tsv output format will omit the braces and quotes, making it simple to read into a variable.  For example: 

```bash
username=$(az account show --query 'user.name' --output tsv)
echo $username 
```

## Selective filtering

This is very useful for outputting selected JSON or TSV for scripting purposes, or for being selective on which columns to show in a table.  It is easiest to demonstrate this by working through an example.

List the VMs in one of your resource groups, using `az vm list --resource-group <resourceGroup> --output table`. 

The table should show all of the VMs, with the name of each server, the resource group and the location, which is of limited use.  

If you run the same command with `--output json` then you will see significantly more information.  If you run `az vm list --help` then you'll find there is a `--show-details` switch.  It is a little slow but has some additional information which is even more useful.

Capture the detailed information into a file using `az vm list --resource-group <resourceGroup> --show-details --output json > vms.json`.  

If you have [Visual Studio Code](/guides/vscode) installed then you can type `code vms.json` to open it up in VS Code. (Example <a href="/guides/cli/vms.json" target="json">vms.json file</a>.)

Examine the JSON output to determine the desired information.  In this example we want to pull only the values for the VM name, size, OS, private and public IP addresses, FQDN and current running state. Working through the nesting, the query should become something like this:

```bash
az vm list --resource-group <resourceGroup> --show-details --output table --query "[*].[name, hardwareProfile.vmSize, storageProfile.osDisk.osType, privateIps, publicIps, fqdns, powerState]"
```

This is known as a multi-select, and provides a far more useful table.  Output this as JSON and you will see that it is an array of arrays, which is why the column headings are Column1-7.  

If the query is tweaked to provide an array of objects then we can control the naming:

```bash
az vm list --resource-group <resourceGroup> --show-details --output json --query "[*].{VM:name, Size:hardwareProfile.vmSize, OS:storageProfile.osDisk.osType, IP:privateIps, PIP:publicIps, FQDN:fqdns, State:powerState}"
```

Note that we have a) changed the second level from square brackets to curly, and b) we have defined our own keys.  Rerun the command, outputting to a table and note the column headers.  (Also note that in the JSON the keys were sorted alphabetically, whilst the tables preserved our selected order.) 

One other thing you will have noticed is that it is very easy to end up with some very long queries.  If scripting then it is recommended to use a `$query` variable for readability, and to support dynamic queries built up from variables.  For example:

```bash
query='[*].{VM:name, Size:hardwareProfile.vmSize, OS:storageProfile.osDisk.osType, IP:privateIps, PIP:publicIps, FQDN:fqdns, State:powerState}'
az vm list --resource-group <resourceGroup> --show-details --output table --query "$query"
```

## Filter Projections

Selecting all elements in in array, or the first or last, is useful.  But often you will want to select based on other criteria.  Rather than using [*]. [0], or [-1], we can use a filter projection base on testing the values, using [?name == 'value'].  These will always produce array slices.

Here are some examples.  I have assumed that you are using the `az configure` defaults to limit to a specific resource group just to shorten the commands:

```bash
az vm list --output json --query "[?location == 'westeurope']" 
az vm list --output json --query "[?storageProfile.osDisk.osType == 'Linux']"
az vm list --output tsv --query "[?name == 'vmName'].id"
```

Let's review each of those in order:

1. Array slice, with all entities where the region is West Europe
2. Another array slice, delving a little further down into the JSON to pull out (at the top level), those entities that have a Linux OS
3. Testing on one value (the VM's name) to output only the ID

The last version is commonly seen when pulling information to be used as variables in scripts.  More on that in the next post.

Compound tests can also be created, using && for a logical AND, and \|\| for a logical OR.  For example `--query "[?tags.env == 'test' || tags.env == 'dev']`.

## Pipes

As in Bash, we can use pipes in our JMESPATH queries to get to the desired point.  As a simple example, compare the following:

```bash
az vm list --output tsv --query "[?name == 'vmName']"
az vm list --output tsv --query "[?name == 'vmName']|[0]"
```

The VM name should be unique within that subscription and resource group, so the first will provide the array slice containing only one element.  In the second command we pull out just that first element, so thet JSON output from that will have stripped out the square braces.

Pipes are very useful when combining filters with multi-selects, and also the functions shown below.  


## Additional Functions

There are a whole host of [functions](http://jmespath.org/specification.html#builtin-functions) that can be very powerful.  Here are a few examples:

* **length**

  Returns the number of elements in an array or array slice. For example, the number of Linux VMs in the resource group can be shown using `az vm list --output tsv --query "length([?storageProfile.osDisk.osType == 'Linux'])"`.

* **contains**, **starts_with**, **ends_with**

  Useful for filtering arrays when matching portions of a string value, e.g.: `az vm list --show-details --output json --query "[?ends_with(storageProfile.osDisk.managedDisk.storageAccountType, 'LRS')]"`

  The `contain` function will also returns true if tested against an array if the search value matches on of the elements.


* **min**, **max**, **min_by**, **max_by**, **sort_by**, **sort**, **reverse**

  The following command will provide an array of all VMs sorted by the OS disk size, with the largest first: ` az vm list --output json --query "reverse(sort_by([], &storageProfile.osDisk.diskSizeGb))"`

* **to_array**, **to_string**, **to_number**

  Use these to force the output of an expression to fit a certain data type.  

In the next section we will have some example integrations with Bash scripting.