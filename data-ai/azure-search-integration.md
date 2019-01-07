---
title: Integrating with Azure Search
date: 2019-01-07
category: data-ai
tags: [azure-search, azure-devops, jquery, jekyll]
author: Ben Coleman
header:
  teaser: /images/teaser/code.png
  overlay_image: /images/header/search.png
excerpt: An overview of the custom integration between Azure Citadel and Azure Search for indexing of static pages, and allowing users to search the site
---
This guide will run through the custom integration that was created for Azure Citadel to use the Azure Search service to index the site and provide search results to users. Although the solution was specific to this site and Jekyll, the working principals and approach could be reused for integrating any static website with Azure Search

[Azure Search](https://azure.microsoft.com/en-gb/services/search/) is a search-as-a-service cloud solution that gives developers APIs and tools for adding a rich search experience over heterogenous content in a range of applications

Using Azure Search with a static site like [Jekyll](https://jekyllrb.com/) presented several challenges
- Generating site content (Markdown and HTML pages) in generalised a data format Azure Search can consume and index
- Getting said data into Azure Search
- Allowing users to query the search from the site, i.e. creating the frontend

# Solution Components
The solution consists of five main elements:
- Jekyll plugin which outputs JSON
- Azure Pipeline for automation of re-indexing
- Azure blob storage
- Azure Search service
- Search page 'client' written in jQuery & HTML5

## End to End Data Flow
The data flow and interaction between the components is as follows

![Overall solution flow](arch.png)


# Jekyll JSON Plugin
First part of the integration requires a way to output the site as JSON documents, so they can be read by Azure Search. The answer was to find a [Jekyll Generator plugin](https://jekyllrb.com/docs/plugins/generators/) that could output JSON. There were several code snippets of Jekyll plugins that would generate JSON, but most were out of date or simply didn't work. A close to working solution was [found here as a Gist](https://https://gist.github.com/egardner/b6bd5d785048ec2d0b2b). This required modification to work with pages rather than posts, to run on the correct subset of pages on the site and also output the JSON with specific fields

The core generate function looks as follows:
```ruby
def generate(site)
  site.pages.each do |page|
    # Set the path to the JSON version of the page
    dest = site.config['destination']

    # Only work with our markdown content, not index pages and others
    unless page.name.end_with? ".md"
      next
    end

    # Munge the destination to .json
    path = page.destination(dest)
    path["#{dest}/"] = ''
    path['/index.html'] = '.json'

    # Convert the page to a hash
    output = page.to_liquid

    # Prepare the output for JSON conversion
    ['dir', 'layout', 'path'].each do |key|
      output.delete(key)
    end

    # Default field for content was 'content', this trips up Azure Search
    # So put generated HTML in content_html and source Markdown in content_md
    output['content_html'] = page.transform
    output['content_md'] = output.delete('content')

    # Queue up for generation
    site.pages << JSONPage.new(site, site.source, File.dirname(path), File.basename(path), output.to_json)
  end
end
```

The [full source of the plugin is here on GitHub](https://github.com/azurecitadel/azurecitadel.github.io/blob/master/_plugins/json-generate.rb). This is placed as a single Ruby file into the sites `_plugins` directory

This plugin is invoked when running a build of the site e.g. `bundle exec jekyll build` and results in `index.json` files being created alongside each of the `index.html` pages. In normal site operation & deployment (e.g. hosting on GitHub pages) these JSON files do nothing and are ignored. However we can build the site and upload the JSON ourselves in a custom build pipeline

An example of the JSON version of a page, the HTML and markdown have been removed to save space:
```json
{
  "comments": true,
  "share": true,
  "toc": true,
  "header": {
    "teaser": "/images/teaser/blueprint.png"
  },
  "title": "A Very Interesting Thing",
  "date": "2018-12-21",
  "category": "stuff",
  "author": "Ben Coleman",
  "tags": [
    "blah",
    "thing"
  ],
  "excerpt": "Some words here explaining about this interesting thing",
  "name": "example.md",
  "url": "/stuff/example/",
  "content_html": "<< HTML GENERATED CONTENT HERE AS A SINGLE LARGE STRING >>",
  "content_md": "<< SOURCE MARKDOWN HERE AS A SINGLE LARGE STRING >>"
}
```

# Azure Pipelines - Build & Re-index
Although Azure Search can regularly run a scheduled re-index scan of its source data, in our case JSON blobs, we still need some process or automation for updating that source data. Azure Pipelines was used for this as it has the ability to run the Jekyll build tasks and is flexible enough to automate the other steps we need.

The automation was done as a single 'Build Pipeline' in Azure Pipelines. The pipeline was defined in YAML and is shown below

```yaml
trigger: none 
pr: none

queue:
  name: Hosted Ubuntu 1604

variables:
  - group: citadel-shared-vars

steps:
- task: UseRubyVersion@0
  displayName: 'Use latest Ruby version'

- script: 'gem install bundler -v 1.17.3'
  displayName: 'Install bundler at version 1.17.3'

- script: 'bundle install'
  displayName: 'Run bundle install'

- script: 'bundle exec jekyll build'
  displayName: 'Run jekyll and build site'

- script: 'az storage blob upload-batch -s _site -d site-json  --pattern "*.json" --account-name=$(storage-acct-name) --account-key="$(storage-acct-key)" --no-progress'
  displayName: 'Upload JSON output to blobs for indexing'

- script: 'curl -v -H "api-key: $(search-admin-key)" -d "" -X POST "https://$(search-account).search.windows.net/indexers/$(search-indexer)/run?api-version=2017-11-11"'
  displayName: 'Call Azure Search API to run reindex'
```

A summary of pipeline:
- Environmental setup (Ruby and bundler)
- Run `bundle exec jekyll build` to build the site, to default output directory `_site`
- Use Azure CLI `az storage blob upload-batch` command to upload output JSON from `_site` to a storage account into a blob container called `site-json`
- Call on the Azure Search indexer to run a re-index, using the Azure Search REST API (using curl)

Secrets and other variables are held in Azure Pipelines as a variable group called `citadel-shared-vars`. This variable group was created and pre-populated using the Azure DevOps Portal, so that no secrets or other variable settings needed to be hardcoded into the pipeline. Secrets include `$(storage-acct-key)` and `$(search-admin-key)`

The pipeline runs on a schedule every 24 hours (and not not on repo pushes/commits as many build pipelines would) and the definition YAML stored in the Git repo that contains the site


# Azure Search Configuration
Azure Search is a powerful search as a service capability available as PaaS within Azure. However for our needs the set up was fairly simple, and Azure Portal was used to create the service instance and configure it with the 'Import Data wizard'. There are three main parts that require configuration and creation: **data source**, **indexer** and the **index**

## Azure Search - Data Source
This was pointed the Azure Storage account using a connection string, and the container named `site-json` used (same as the configuration of the 'Upload JSON' pipeline task)

## Azure Search - Indexer
The indexer was set up to read from the above data source, with **parsing mode set to JSON**. Scheduling was disabled as the re-index is invoked regularly from the pipeline. As there were are some JSON files contained in the site source these get uploaded with the `az storage blob upload-batch` step and there's no way to filter them out. To get round this, the failed items value was simply increased to allow the indexer to skip over any JSON docs it finds which aren't in the correct format.

![Azure Search Indexer](./indexer.png)

## Azure Search - Index
The majority of the Azure Search configuration is done on the index, this determines which fields will be extracted out of the JSON and how they are used.

By default the JSON indexer will put all of the JSON parsed into a huge field called `content`, this isn't a optimal way of using the data we have, so a more refined configuration was used: 
- The `content` field is removed (retrievable unticked)
- The `content_md` & `title` fields are marked as searchable & retrievable
- The `url`. `author`, `date`, `excerpt` and `header` fields are marked as retrievable
- All fields are strings

If you refer back to the example JSON document you will notice the `header` field is in fact not a string but an object with nested fields inside it. As we fetch it as a string, this means we get a small chunk of serialized JSON inside it, however we can easily handle this on the client

![Azure Search Index](./index.png)

# Search Page  
To consume or use the search index and actually find results, a client page was created using jQuery. As the site in question is static HTML more modern JavaScript frameworks were deemed to complex to integrate with the site. The search experience is a single query field, and results are fetched & shown in real time as they are typed

The page is very simple, mostly self contained & consists of:
- Search input field bound with *keyup* events (using jQuery)
- Area for results to dynamically be displayed
- Function to call Azure Search query API (using jQuery AJAX), parse results & update the page
- Delay callback function
- Simple spinner to give user feedback on activity

The basic form is the Azure Search query API is used as follows
```http
GET https://${AZURE_SEARCH_ACCOUNT}.search.windows.net/indexes/${AZURE_SEARCH_INDEX}/docs?api-version=2017-11-11&api-key=${AZURE_SEARCH_KEY}&search={QUERY}
```

The delay function prevents us overloading the API with requests, so API calls are only made after the user has stopped typing for 500 milliseconds

The API results are parsed as JSON, and certain fields such as `header` run through `JSON.parse()` as they contain embedded JSON strings for nested objects. The `url` can be used to form a link to the relevant page, and fields such as `header.teaser`, `title`, `excerpt`, `date` & `author` allow for display of meaningful results on the page. The parsed results are pushed back to the page with a dynamic element and jQuery append. 

The source of the page created can [be found in the Citadel GitHub repo](https://github.com/azurecitadel/azurecitadel.github.io/blob/master/_pages/search.html)

For a working demonstration simply click the [search link](/search) on this site's toolbar!
