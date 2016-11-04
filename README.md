
# ReqCheck

This is the original ReqCheck Project, developed by the Code for America's 2016 Kansas City, Missouri (KCMO) Fellowship Team in collaraboration with the KCMO Health Department.

A special thank you to the staff at the [Kansas City Health Department](http://kcmo.gov/health/clinic-services/) and the staff at the [Centers for Disease Control and Prevention (CDC)](http://www.cdc.gov/vaccines/programs/iis/cdsi.html).

This project references requirements from the CDC in order to evaluate a patient's vaccine record. The evaluation will say whether a patient is 'up to date' or 'needs vaccines'.

This project is a prototype, and has limited functionality. It can currently tell between a up-to-date and non-up-to-date records. However, it is unable to evaluate records currently in the midst of a check up schedule.

![ReqCheck at work](https://media.giphy.com/media/3o6Zt5O09Lxx6chXIQ/source.gif)

This project exists to enable healthcare professionals to evaluate a vaccine record with the up to date CDC requirements.

The project was started after understanding the skilled resources necessary to evaluate a patient's record, and recognizing the benefit for a health clinic's work flow if one is able to evaluate a patient's record from the moment they walk in. It is designed to be a simple tool usable by a health clinic's intake staff.

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

## Authors

* **[Rachel Edelman](http://racheledelman.com/)** - Design & Frontend Development - [Github](https://github.com/racheledelman)
* **[Kevin Berry](http://kevin-berry.com)** - Development - [Github](https://github.com/lostmarinero)
* **[Jessica Cole](https://about.me/jessicacole)** - Project Management - [Github](https://github.com/jessonawhim)

??**Also a special thanks to [Ben Golder](https://github.com/bengolder) for his mentorship on this project**??

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under Code for America's copyright. Please see the [License file](LICENSE.md)

## Acknowledgments

Thank you to our funders and the Code for America staff for their support. Without this support, this project would not have been possible.

* [Health Care Foundation of Greater Kansas City](http://hcfgkc.org/)
* [The Robert Wood Johnson Foundation](http://www.rwjf.org/)
* [Reach Healthcare Foundation](https://reachhealth.org/)
* [ANY ADDITIONAL FUNDERS?](https://)

Also, thank you to everyone involved in the research and development

* The Staff at the Kansas City, Missouri Health Department
* The Center for Disease Control and Prevention
* [Ben Golder](https://github.com/bengolder)


## HIPAA Compliance

The [Health Insurance Portability and Accountability Act (HIPAA)](https://en.wikipedia.org/wiki/Health_Insurance_Portability_and_Accountability_Act) outlines national security standards intended to protect health data created, received, maintained, or transmitted electronically.

To review what has been done, please visit the [HIPAA Readme](HIPAA.md).



To be done:
    How to import a new group antigen import requirements
        Delete old ones
        Import new ones
        Run all the tests
    Overview of 3 separate components (api, algorithm, kcmohd frontend)
    Explanation of the database component (getting data out of the application)