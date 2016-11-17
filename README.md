
# ReqCheck

This is the original ReqCheck Project, developed by the Code for America's 2016 Kansas City, Missouri (KCMO) Fellowship Team in collaraboration with the KCMO Health Department.

A special thank you to the staff at the [Kansas City Health Department](http://kcmo.gov/health/clinic-services/) and the staff at the [Centers for Disease Control and Prevention (CDC)](http://www.cdc.gov/vaccines/programs/iis/cdsi.html).

This project references requirements from the CDC in order to evaluate a patient's vaccine record. The evaluation will say whether a patient is 'up to date' or 'needs vaccines'.

This project is a prototype, and has limited functionality. It can currently tell between a up-to-date and non-up-to-date records. However, it is unable to evaluate records currently in the midst of a check up schedule.

[See how it works here!](https://media.giphy.com/media/3o6Zt5O09Lxx6chXIQ/source.gif)

This project exists to enable healthcare professionals to evaluate a vaccine record with the up to date CDC requirements.

The project was started after understanding the skilled resources necessary to evaluate a patient's record, and recognizing the benefit for a health clinic's work flow if one is able to evaluate a patient's record from the moment they walk in. It is designed to be a simple tool usable by a health clinic's intake staff.

## How it works
This project was developed using the information provided by the [CDC's implementation guide](http://www.cdc.gov/vaccines/programs/iis/interop-proj/downloads/logic-spec-acip-rec.pdf). The CDC provides guidelines for using the supporting data published yearly, and this information has been interpreted from that guide.

### Terminology
There are many terms that are important for interpretting the algorithm. Many of them are provided below. Others can be found in the [CDC's implementation guide]'s glossary.

* **Antigen** - Foreign substance that triggers immune response. An antigen has many antigen series.
* **Antigen Series** - One possible path to achieve perceived immunity to a disease. Has many antigen series doses.
* **Patient Series** - Patient specified series required to satisfy a recommendation. A patient series is created with an antigen series combined with an individual patient, and is unique to the patient. Has many target doses.
* **Antigen Series Dose** - Individually defined dose within an Antigen Series. Has many Antigen Series Dose Vaccines.
* **Target Dose** - Patient specified dose required to satisfy a recommendation. A target dose is created with an antigen series dose combined with an individual patient, and is unique to the patient. A target doses is evaluated against an Antigen Administered Record to get a Target Dose Status (satisfied, not satisfied).
* **Vaccine Dose Administered** - Record of an event where a vaccine was administered. Has many Antigen Administered Records and one vaccine.
* **Vaccine** - Specific instance of medicine (which contains antigens).
* **Antigen Administered Record** - Created for each antigen contained within a Vaccine Dose Administered. A single vaccine dose administered could have many antigen administered records
    * **Example:** MMR vaccine dose administered has 3 antigen administered records. 1 each for the antigens for Measles, Mumps and Rubella. 
* **Vaccine Group (Classification category)** - Describes broad categories of diseases. Can be one disease or many (Can have one or more antigens). This is usually to categorize diseases into groups known/used by medical professionals, and usually reflects a specific vaccine.
    * **Example:** MMR is used for Measles, Mumps, Rubella, which is 3 separate diseases with 3 separate antigens
* **Interval** - Space of time between a vaccine dose administered (and therefor antigen administered records as well)

For a visual representation of how they work together, please see [this diagram](WHERE IS RACHEL!).

### The Algorithm
The algorithm is broken into many parts and runs through many different processes. All of the information from the CDC has been imported into the Postgres Database. It is then used to build patient specific requirements to check against the patient's vaccine record.

#### Step 1
All of the patient's vaccine doses administered are taken and used to create antigen administered records. A vaccine dose administered with multiple antigens creates multiple antigen administered records. The antigen administered records are then split into groups based on the specific Antigen they address.

#### Step 2
Each antigen has multiple antigen series ('paths' to immunization, as defined by the CDC). Each antigen series has many antigen series doses. This information is necessary to create ***PATIENT SPECIFIC*** information, used to evaluate the patient's vaccine record.

1. Each antigen combines the individual patient's information with each antigen series, creating many patient series nested below it
2. Each patient series passes the patient information to each antigen series dose, creating the target doses nested below it

#### Step 3
Evaluation of the patient serieses against the antigen administered records

1. Each antigen passes the patient and antigen specific 'antigen administered records' to each patient series
2. The patient series lines each 'antigen administered record' up to each target dose
3. The patient series loops through the target doses
    * If the target dose is *NOT* able to be evaluated (for example, sometimes the patient is not old enough):
        * It is dropped aside
    * If the target dose is able to be evaluated:
        * The target dose is evaluated using its specified logic against the next antigen administered record in line*
        * If the target dose is satisfied:
            * The target dose is marked 'satisfied'
        * If the target dose is not satisfied (due to invalid age, invalid interval from the previous antigen administered record):
            * The antigen administered record is removed
            * If there are more antigen administered records left to evaluate:
                * The next antigen administered record is evaluated against the target dose
            * If there are no more antigen administered records:
                * The target dose is marked 'not_satisfied'
4. After all target doses have been evaluated, the patient series is evaluated based on the individual statuses of each target dose and the patient series logic. The patient series is given an evaluation status.

***

##### Evaluating the Target Dose & Order of Evaluation
The target dose is evaluated in the following order or requirements:
    
1. Evaluate Dose Administered Condition
    * Was the dose expired when given?
1. Evaluate Conditional Skip
    * Is there a reason the dose can be skipped, such as if the patient has had a certain number of doses before a certain age?
1. Evaluate Age
    * Did the patient receive the dose at the correct age?
1. Evaluate Interval
    * Did enough time pass since the previous dose?
1. Evaluate Vaccine Administered
    * Is the dose given listed amongst allowable or preferrable vaccines?
1. Evaluate Gender
    * Is the patient the correct gender for the target dose?
1. Satisfy Target Dose 
    * Were all the requirements satisfied

If the patient has satisfied the target dose, it is market 'satisfied'. If not, it is marked 'not_satisfied' and given a reason as to why.

***

##### Individual Evaluation Process
The evaluations of 'Age', 'Interval', 'Vaccine Administered' and 'Gender' follow similar paths, and done by 'Evaluator' objects. This is the series of events.

###### Build Attibutes
The CDC logic stored in the Target Dose is used to build patient specific 'attributes', which are stored in a hash.
    
* Patient specfic attributes often times are age/date based.
* An example is that if Target Dose has a minimum_age of '8 months', the attribute 'minimum_age_date' will be the patients date of birth plus 8 months

###### Analyze Attributes
The attributes are then analyzed against the data from the Vaccine Dose that was administered to the patient.

* An example is that if attribute 'minimum_age_date' is December 13, 2015 and the Vaccine Dose Date is December 18, 2015, the analysis of 'minimum_age_date' will be `true`

###### Get Evaluation
The attribute analyses are then evaluated against the different evaluation statuses. If the evaluation is `not_satisfied` for any reason, the specific reason will be given as an `evaluation_reason`.

* If the 'minimum_age_date' is `false`, then the `evaluation_reason` could be `too_young`
* If the 'maximum_age_date' is `false`, then the `evaluation_reason` could be `too_old`

***

#### Step 4
Each antigen is evaluated based on the most complete patient series. If there is a patient series that is either 'complete' or 'immune', then the antigen is evaluated to be 'complete' or 'immune'.

Do note that 'immune' takes presidence over 'complete', as 'immune' means there is no more target doses (all satisfied), where 'complete' is only if the patient is up to date (but will need more vaccine doses in the future).

If there is no series that is 'complete', then the Antigen is marked 'not complete'.

#### Step 5
All of the Antigen Evaluations are then grouped into 'Vaccine Groups', as defined by the CDC in the structured data. Vaccine groups are how medical professionals categorize vaccines (instead of by antigen).

Each vaccine group is then evaluated for the antigen 'completeness'. If all antigen's are 'complete' or 'immune', then that status is given to the vaccine group. If an antigen has a 'not_complete' evaluation status, then the Vaccine Group is given an evaluation status of 'not_complete'.

#### Step 6
The entire record is then evaluated by required vaccine groups. **This information has specifically been hard coded to fit the Kansas City, Missouri Health Department.** If all required vaccine groups are 'complete' or 'immune', then the record is marked as 'comlete'. Otherwise, it is 'not_complete'.


## Getting Started

### Built With

* [Ruby 2.3.1](https://www.ruby-lang.org/en/news/2016/04/26/ruby-2-3-1-released/)
* [Rails 4](http://guides.rubyonrails.org/4_0_release_notes.html)
* [Postgres 9.5.4](https://www.postgresql.org/docs/9.6/static/release-9-5-4.html)
* [Bundler 1.13.5](https://rubygems.org/gems/bundler)

Ensure you are using Ruby version 2.3.1.
`ruby --version`

Ensure you have Rails 4 installed
`rails --version`

Ensure you have Postgres 9.5.4 installed
`postgres -V`

Ensure you have Bundler 1.13.5 installed
`bundle --version`

## Installing

#### Environment Variables
* `RAILS_ENV=[development]` — Environment variable to tell rails application which configuration to use
* `DATABASE_URL=[db connection string]`
* `EXTRACTOR_NAME=[BasicAuth Name]` — Basic Auth Name for accessing the DataImporterApi
* `EXTRACTOR_PASSWORD=[BasicAuth Password]` — Basic Auth Password for accessing the DataImporterApi

#### Clone the Repo
```
git clone https://github.com/codeforamerica/ReqCheck.git
```

#### Install Dependencies
```
bundle install
```

>**Note: Qt Dependency and Installation Issues**
>capybara-webkit depends on a WebKit implementation from Qt, a cross-platform
>development toolkit. You'll need to download the Qt libraries to build and
>install the gem. You can find instructions for downloading and installing Qt
>on the [capybara-webkit wiki](https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit). capybara-webkit requires Qt version 4.8 or greater.

#### Create/Migrate Database
```
bundle exec rake db:create;
bundle exec rake db:migrate;
```

#### Seed the Database
This is not required, but will provide test data
```
bundle exec rake db:seed;
```

#### Local Server
To get the local server going, use Rail's built in test server
```
bundle exec rails s
```

## Running the tests
The project uses [rspec](http://) for controller tests and unit tests.

The tests automatically seed the test database with all objects needed for the tests using [Factory Girl](http://)

```
rspec spec
```

### Feature tests
The project uses rspec combined with [capybara](http://) for feature tests (also known as end to end tests).
```
rspec spec ./spec/features
```

### Security Testing
Although 3rd party packages are not guaranteed to ensure your app is secure, it is a good idea to run a code security analyzer. For this, we use [Brakeman](http://brakemanscanner.org/)

1. First, cd into your repo (`cd reqcheck`)
2. To install, run `gem install brakeman`
3. Run `brakeman`

### Coding Style Tests
This project uses [Rubocop](http://) to ensure the formatting and syntax is correct. This will help produce easily readable code that follows best practices. Rubocop follows the [Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide).

1. First, cd into your repo (`cd reqcheck`)
2. To install, run `gem install rubocop`
3. Run `rubocop`


## Deployment

This project will be fully hosted once configuration of the servers are completed so that they are in compliance with HIPAA.

**PLEASE NOTE: This application does not guarantee HIPAA compliance. It is the responsibility of the implementers to ensure it passes their HIPAA compliance standards. The developing team and organization assumes no responsibility for this.**

This project was deployed in development on [aptible](http://aptible.com/) using [docker](https://www.docker.com/) and [puma](http://puma.io/).

The development specifics can be found in the following files:

* [Procfile](https://github.com/codeforamerica/ReqCheck/blob/master/Procfile)
* [Dockerfile](https://github.com/codeforamerica/ReqCheck/blob/master/Dockerfile)

## Contribute
Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

### Features Needed
We have many features that need to be implemented. A high priority would be:

* Ability to forecast next vaccines
* Upload feature in the admin panel to upload new CDC requirements and delete past ones, followed by running tests to see if they all still pass
* HIPAA compliance auditing in the admin panel

## Authors

* **[Rachel Edelman](http://racheledelman.com/)** - Design & Frontend Development - [Github](https://github.com/racheledelman)
* **[Kevin Berry](http://kevin-berry.com)** - Development - [Github](https://github.com/lostmarinero)
* **[Jessica Cole](https://about.me/jessicacole)** - Project Management - [Github](https://github.com/jessonawhim)

**Also a special thanks to [Ben Golder](https://github.com/bengolder) for his mentorship on this project**

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under Code for America's copyright. Please see the [License file](LICENSE.md)

## Acknowledgments

Thank you to our funders and the Code for America staff for their support. Without this support, this project would not have been possible.

* [Health Care Foundation of Greater Kansas City](http://hcfgkc.org/)
* [The Robert Wood Johnson Foundation](http://www.rwjf.org/)
* [REACH Healthcare Foundation](https://reachhealth.org/)
* [Google Fiber](https://fiber.google.com/)

Also, thank you to everyone involved in the research and development

* The Staff at the Kansas City, Missouri Health Department
* The Center for Disease Control and Prevention
* [Ben Golder](https://github.com/bengolder)


## HIPAA Compliance

The [Health Insurance Portability and Accountability Act (HIPAA)](https://en.wikipedia.org/wiki/Health_Insurance_Portability_and_Accountability_Act) outlines national security standards intended to protect health data created, received, maintained, or transmitted electronically.

To review what has been done, please visit the [HIPAA Readme](HIPAA.md).

