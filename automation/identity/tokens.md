---
title: "Working with Azure Resource Manager tokens"
date: 2020-04-29
author: Richard Cheney
category: automation
published: false
hidden: true
featured: false
comments: true
tags: [ identity, RBAC, tokens, REST, CLI ]
toc_depth: 3
header:
  overlay_image: images/header/yellowpages.jpg
  teaser: images/teaser/identity.png
sidebar:
  nav: "identity"
excerpt: Work with Azure Resource Manager tokens using REST APIs and the curl utility, before moving on to the CLI. Then see how it varies with service principals and managed identities.
---

## Introduction

OK, let's do this the hard way. We'll get a token for a service principal, then list, create and delete resource groups using only curl and jq and the ARM REST API. No shortcuts.

This will give you an appreciation of what the CLIs, SDKs, portal etc. are doing for you as all of these eventually go through the REST APIs.

We'll then look at how the Azure CLI caches tokens in the accessTokens.json file.

We'll then look at differences with service principals when using secrets and certs.

Finally we'll look at a managed identity and how that acquires its token.

## REST API



## Azure CLI tokens

1. Log out of Azure

    ```bash
    az logout
    ```

1. Delete your accessTokens.json

    ```bash
    rm ~/.azure/accessTokens.json
    ```

    > This is your Azure access token cache.

1. Log in to Azure

    ```bash
    az login
    ```

    Follow the prompts to log back into Azure. Once successful then your current subscription context will be shown.

1. Display the structure of the accessTokens.json file

    ```bash
    jq . <  ~/.azure/accessTokens.json | cut -c1-80
    ```

    Example output:

    ```json
    [
      {
        "tokenType": "Bearer",
        "expiresIn": 3599,
        "expiresOn": "2020-04-22 17:25:23.747411",
        "resource": "https://management.core.windows.net/",
        "accessToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IllNRUxIVDBndmIw"
        "refreshToken": "AQABAAAAAAAm-06blBE1TpVMil8KPQ41PDWD8bsQi5w-9GfV_pGrAkzHvZb"
        "identityProvider": "live.com",
        "userId": "lighthousecustomer@outlook.com",
        "isMRRT": true,
        "_clientId": "04b07795-8ddb-461a-bbee-02f9e1bf7b46",
        "_authority": "https://login.microsoftonline.com/common"
      },
      {
        "tokenType": "Bearer",
        "expiresIn": 3599,
        "expiresOn": "2020-04-22 17:25:24.330438",
        "resource": "https://management.core.windows.net/",
        "accessToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IllNRUxIVDBndmIw"
        "refreshToken": "AQABAAAAAAAm-06blBE1TpVMil8KPQ41PDWD8bsQi5w-9GfV_pGrAkzHvZb"
        "identityProvider": "live.com",
        "userId": "lighthousecustomer@outlook.com",
        "isMRRT": true,
        "_clientId": "04b07795-8ddb-461a-bbee-02f9e1bf7b46",
        "_authority": "https://login.microsoftonline.com/ce508eb3-7354-4fb6-9101-03b"
      }
    ]
    ```

    > The output width has been truncated to 80 characters for brevity.

    When you authenticate then it creates two bearer tokens for your userId for accessing the <https://management.core.windows.net/> resource.

    It has one for your specific tenantId, and the other is for the common tenant. (The common tenant is a value used for both personal Microsoft accounts and for work/school accounts. See the [OpenID Connect](https://docs.microsoft.com/azure/active-directory/develop/v2-protocols-oidc) docs for more info.)

1. Display the access tokens in full

    ```bash
    jq .[].accessToken < ~/.azure/accessTokens.json
    ```

    Note that the two accessTokens are different.

1. Display your current access token

    ```bash
    az account get-access-token --output jsonc
    ```

    The access token should be the same as the tenantId specific accessToken in the cache.

1. Set a variable to the token value

    ```bash
    token=$(az account get-access-token --query accessToken --output tsv)
    echo $token
    ```

1. Access the Microsoft Graph

    ```bash
    az ad signed-in-user show --output jsonc
    ```

1. Display the last accessToken in the accessTokens.json array

    ```bash
    jq .[-1] < ~/.azure/accessTokens.json | cut -c1-80
    ```

    ```json
    {
      "tokenType": "Bearer",
      "expiresIn": 3599,
      "expiresOn": "2020-04-22 18:03:09.645851",
      "resource": "https://graph.windows.net/",
      "accessToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IkN0VHVoTUptRDVN"
      "refreshToken": "AQABAAAAAAAm-06blBE1TpVMil8KPQ41bfs2MUMeU-GGRlcG0ZvR9VQ1-OL"
      "identityProvider": "live.com",
      "userId": "lighthousecustomer@outlook.com",
      "isMRRT": true,
      "_clientId": "04b07795-8ddb-461a-bbee-02f9e1bf7b46",
      "_authority": "https://login.microsoftonline.com/ce508eb3-7354-4fb6-9101-03b"
    }
    ```

    More access tokens will be generated and cached in the file dependant on

    * the userId or servicePrincipalId
    * the authority / identityProvider
    * the resource being accessed

## Service Principals

Stuff

## Managed Identities

More stuff

## Summary

Summary stuff

<CHANGE ME>

[◄ Lab 2: Service Principals & Managed Identities](../lab2){: .btn .btn--inverse} [▲ Index](../#labs){: .btn .btn--inverse} [Lab 4: Service Principals ►](../lab4){: .btn .btn--primary}
