# ETDA Explore

ETDA (Electronic Theses and Dissertations Application) Explore is a Ruby on Rails web application build on Blacklight that leverages the metadata of released electronic theses and dissertations to permit the search and retrieval of work preserved by the Pennsylvania State University Libraries. ETDA Explore is the discovery portion part of the larger ETDA service.  ETDA Workflow (the other portion) handles the submission, format review, electronic approval, and short-term storage workflow for students who author electronic theses and dissertations and for the administrators who review the work and release the documents according to policy and the author's wishes.
                                                   
The application is used by each of several different "partners". Currently these partners are the Graduate School, the Schreyer Honors College, the Millennium Scholars Program, and The School of Science Engineering and Technology. Each partner has its own instance of the application along with its own database.

### Dependencies

| Software |  Version |
|----------|------|
| `ruby`    |  2.7 |
| `rails`   |  7 |
| `solr`   |  8 |
| `mysql` | 8 |

### Configuration

All configuration is done via environment variables. the .envrc.example file shows the apps tunables
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
