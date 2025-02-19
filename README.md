# ETDA Explore

ETDA (Electronic Theses and Dissertations Application) Explore is a Ruby on Rails web application build on Blacklight that leverages the metadata of released electronic theses and dissertations to permit the search and retrieval of work preserved by the Pennsylvania State University Libraries. ETDA Explore is the discovery portion of the larger ETDA service.  ETDA Workflow (the other portion: https://github.com/psu-libraries/etda_workflow) handles the submission, format review, electronic committee approval, and final submission review for students who author electronic theses and dissertations.  ETDA Workflow allows administrators to review the work and release the documents according to policy and the author's wishes.
                                                   
The application is used by each of several different "partners". Currently these partners are the Graduate School, the Schreyer Honors College, the Millennium Scholars Program, and The School of Science Engineering and Technology. Each partner has its own instance of the application along with its own database.

### Dependencies

| Software |  Version |
|----------|------|
| `ruby`    |  3.4 |
| `rails`   |  7 |
| `solr`   |  8 |
| `mysql` | 8 |

### Configuration

All configuration is done via environment variables. The .envrc.example file shows the apps tunables
```
cp .envrc.example .envrc
source .envrc
```

### Development Setup

Docker compose is used to setup the mysql and solr instances locally.

From the project root directory:

Run the mysql and solr containers:

    docker compose up --build

Omit `--build` if you've already built the images.

Run `bundle install` if gems have not been installed yet.

Load configset and create a solr collection:

    bundle exec rake solr:init
    
Load fixture data into solr:

    bundle exec rake solr:load_fixtures    
    
Create database and run database migrations:

    bundle exec rake db:create
    bundle exec rake db:migrate
    
Finally run the rails server and take a look at the app from the browser at localhost:3000:

    bundle exec rails s
    
Note: To reset the solr collection and configset run:
      
    bundle exec rake solr:reset

### Testing

To run the test suite run:

    RAILS_ENV=test bundle exec rspec
    
To run the linter "niftany":

    bundle exec niftany

### OAI Endpoint

ETDA Explore uses the blacklight_oai_provider gem to generate an OAI-PMH endpoint.  The endpoint can be reached at `/catalog/oai`; it returns XML.

You can query the endpoint by date range with the following query pattern:

    ?verb=ListRecords&from=2021-01-01&until=2021-05-29&metadataPrefix=oai_dc


### Deployment

To deploy a preview, prepend your branch name with `preview/` like so: `preview/your-branch-name`.  A preview will deploy when you push this branch to GitHub.

Any PRs merged to main will automatically be deployed to QA.

To initiate a production deploy, create a new release.  Then, merge the automatically created PR in the config repo: https://github.com/psu-libraries/etda-config
