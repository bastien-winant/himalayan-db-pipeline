# Himalayan Database Modeling
## Overview
### Objective
The aim of this project is to create a suite of analytics-ready datasets from the __Himalayan Database__ that allow users to answer questions about past Himalayan climbing expeditions.

It supports analytical work by processing and transforming a raw dataset into a cleaned subject-oriented data warehouse.

### What are we trying to measure
#### Scope
The focus of the project is on __expedition outcomes, and the factors that influence them__. To this end, the datasets are built around a specific set of entities, events, and metrics of interest.

Using simple queries, users are able to uncover patterns relating specific event types (e.g. expedition success, climber injury) to related factors (e.g. climbing season, route followed, climber age).

The following are examples of questions that the datasets are designed to answer:
- _what is the expedition success rate on a given route?_
- _how many expeditions have been attempted to a given peak?_
- _how long is an expedition to a given peak expected to last?_
- _does member experience impact expedition success rate?_
- _does a given route have a significantly high fatality rate?_

#### Key variables

*Entities*
- Expeditions
- Peaks
- Routes
- Members

*Events*
- Ascents
- Summits
- Accidents

*KPIs*
- Success rate
- Time-to-summit
- Fatality rate

*Confounding variables*
- Weather
- Oxygen use
- Climber experience
- Team composition
- Sponsorship

## Data Source
### Format
The data source for this project is _The Himalayan Database_, a periodically updated public archive of Himalayan climbing expeditions. It is distributed as a set of downloadable static files on [the publisher's website](https://thehimalayandb.com). 

The file type used is __DBF (DataBase File)__, a tabular binary database format introduced for the dBASE platform. In this project, the files are ingested programatically using Python's [__dbfread__ library](https://dbfread.readthedocs.io).

Despite coming in tabular format, the raw data has several deficiencies that makes it unfit to support analytics workloads:
- non-atomic values
- inconsistent data types
- free-form unstructured text
- no primary keys
- empty columns

In this project, we use an ETL workflow to clean, format, and transform the raw data after it has been ingested.

### Granularity
_The Himalayan Database_ provides detailed information about every major climbing expedition in the Himalayas dating back to 1905.

The raw data itself has been modeled into separate tables (each contained in its own DBF file). Three of these tables are of interest to this project: peaks, expeditions, and members. Below is a description of the contents found in each of them.

#### Peaks
This dataset contains an entry for each Himalayan peak. It contains details such as height, location, and climbing restrictions.

Most variables in this dataset are static or slowly-changing dimensions.

#### Expeditions
Every entry in this table corresponds to a single expedition

#### Members
This dataset lists details about individual members across for each expedition. It has the highest level of granularity across tables: every row corresponds to a specific participant.

The included variables are a combination of static demographic details (gender, age, occupation,...) and expedition-related facts (summit attempts, injuries, oxygen use,...).

### Freshness
As per the source documentation, _The Himalayan Database_ is updated twice per year.
### Publisher
_The Himalayan Database_ is maintained and published by the non-profit organization of the same name