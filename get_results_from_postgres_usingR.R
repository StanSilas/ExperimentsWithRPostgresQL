options(width=10000) 
rm(list=ls())

require(RPostgreSQL)
require(DBI)
require(tidyr)
require(yaml)
library(slackr)

config = yaml.load_file('/home/config')

print("connecting to prod db")
# make connection
prod_con <- dbConnect(RPostgreSQL::PostgreSQL(), dbname = 'mydb_name', 
                      host = 'db.vivirk.testing.io',
                      port = 5432, # or any other port specified by your DBA
                      user = config$db$username,
                      password = config$db$password)

print ("connected.")



if(weekdays(Sys.Date())=="Monday"){ 
  all_state_counts<-'select date(fileuploads.created),count(*) as total_count, state 
  from fileuploads
  where DATE(fileuploads.created)=CURRENT_DATE - interval \'3 day\'
  group by DATE(fileuploads.created), state
  order by total_count desc;' 
} else {
  all_state_counts<-'select date(fileuploads.created),count(*) as total_count, state 
        from fileuploads
        where DATE(fileuploads.created)=CURRENT_DATE - interval \'1 day\'
        group by DATE(fileuploads.created), state
        order by total_count desc;'
}
all_state_counts_res<-dbGetQuery(prod_con,all_state_counts)
proc.time() - ptm

View(all_state_counts_res)

#disconnect from db
dbDisconnect(prod_con)

# now do other analysis
