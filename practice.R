#What: Software Carpentry Workshop, R Practice
#When: October 18th, 2016
#Who: Diego Barroso
#Where: Hatcher Library, Room 100, at U of Michigan, Ann Arbor
# This is an extra test line. Also, re-added hashes below to match end of line.
###############################################################################

# commands issued during Introduction to R session

install.packages('RSQLite')
library(RSQLite)
conn <- dbConnect(SQLite(), dbname='/home/barroso/Desktop/Rworkshop/survey.sqlite')
tables <-dbListTables(conn)
class(tables)
surveys <- dbGetQuery(conn, 'SELECT * FROM surveys')
head(surveys)
summary(surveys)
surveys <- dbGetQuery(conn, 'SELECT * FROM surveys JOIN species ON surveys.species_id = species.species_id JOIN plots ON surveys.plot_id = plots.plot_id;')
summary(surveys)
head(surveys)
names(surveys[,1:4])
surveys <- read.csv('/home/barroso/Desktop/Rworkshop/ecology.csv')
summary(surveys)
head(surveys)
class(surveys)
x1 <- c(1,2,3)
class(x1)
typeof(x1)
x2<-c('a','b','c')
typeof(x2)
df<-data.frame(x1=c(TRUE,FALSE,TRUE),x2=c(1,'red',2))
df
class(df$x1)
typeof(df$x1)
x1
list(99,TRUE,'balloons')
list(1:10, c(TRUE,FALSE))
str(surveys)
class(surveys$year) # Gives us a vector
class(surveys['year']) # Gives a data frame
head(surveys$year) # Called "integer" (an "integer" vector?)
head(surveys['year']) 
class(surveys[,4])
class(surveys[['year']])
# Factors -- are used to represent categorical data, and can be ordered, or un-ordered
# Factors are stored as integers that code for human-readable labels
str(surveys)
surveys$sex
levels(surveys$sex)
nlevels(surveys$sex)
spice <- factor(c('low', 'medium', 'low', 'high'))
?factor # to bring up "the man page" 
levels(spice)
max(spice)
# Trying an ordered vector for factors now:
spice<-factor(c('low','medium','high'), levels = c('low', 'medium', 'high'), ordered=TRUE)
max(spice)
# Easier to create ordered factors with this function 'ordered'; we have re-ordered the factors in inverse order
spice <- ordered(spice, levels = c('high', 'medium', 'low'))
max(spice)
tabulation <- table(surveys$taxa)
tabulation
barplot(tabulation)
max(surveys$taxa)
# Now, try to order by frequency in the surveys dataset (use 'ordered' function)
?ordered
surveys$taxa<-ordered(surveys$taxa, levels=c('Rodent','Bird','Rabbit','Reptile'))
surveys$taxa
# Here, we are chaining commands -- kind of like a pipe in Linux -- where the table is being fed into barplot
barplot(table(surveys$taxa))
tabulation
levels(surveys$taxa)
# Cross-tabulation
table(surveys$year, surveys$taxa)
# To minimize typing -- not typing "surveys" over and over again -- use WITH (to tell it to look within 'surveys'):
with(surveys, table(year,taxa))
# Disconnect from the database; remove the connection from the workspace
dbDisconnect(conn)
rm(conn)
order(surveys$weight) # returns indices
sort(surveys$weight)  # returns sorted values
# What was the median weight of each rodent species between 1980 and 1990? (going to learn to subset dataframes)
surveys$taxa == 'Rodent' # Returns a logical vector
length(surveys$taxa == 'Rodent')
dim(surveys) # same number of rows as original dataset
# Grab all the rows were Rodent = True
surveys[surveys$taxa == 'Rodent', 'taxa']
# Grab all from 1980 thru 1990
years_of_interest=1980:1990
# Combining conditionals: TRUE& TRUE
surveys[surveys$year %in% seq.int(1980,1990) & surveys$taxa == 'Rodent',]
# or
surveys[(surveys$year >=1980 & surveys$year <= 1990) & surveys$taxa == 'Rodent',]
# Bar (pipe) means OR
# ON TO DPLYR
install.packages('dplyr')
library(dplyr)
output<-select(surveys,year,taxa,weight)
?select
head(output)
filter(surveys, taxa == 'Rodent')
# OR
dplyr::filter(surveys, taxa == 'Rodent')
filter(select(surveys, year, taxa, weight), taxa = 'Rodent')
# dplyr allows for pipes; new syntax:
# IN DPLYR, THE PIPE SIGN IS: %>%
rodent_surveys <- surveys %>% 
     filter(taxa == 'Rodent') %>%
     select(year, taxa, weight)
# Challenge: Subset surveys to only include Rodent surveys between 1980 and 1990
rodent_surveys <- surveys %>% 
  filter(taxa == 'Rodent') %>%
    year %in% seq.int(1980,1990)) %>%
  select(year, taxa, weight)
# all.equal command checks whether the output from one command is equal to the output from another command
all.equal(rodent_surveys, rodent_surveys2)
# UNIT CONVERSIONS: can use function called MUTATE, adds columns to the dataframe:
surveys %>%
     Mutate(weight_kg = weight / 1000)
# OUTPUT can also be directly piped into the HEAD or TAIL function, e.g.:
surveys %>%
  Mutate(weight_kg = weight / 1000) %>%
  tail()

# From plyr, dplyr inherits the Split, Apply, Combine function:
# Can split into subsets, apply different transformations to each, and then re-combine; e.g.:
# This lists median weights by species, excluding the NA's:
surveys %>%
    filter(!is.na(weight)) %>%
    group_by(species_id) %>%
    summarize(med_weight = median(weight)) %>%
# Output is no longer a dataframe, but a "tibble", which cuts itself short pretty soon; so
# to see the whole "tibble", you'd have to add a print command at the end:
   print(n=25)
# To answer original question, for example:
surveys %>%
  filter(!is.na(weight), taxa == 'Rodent',
          year %in% 1980:1990) %>%
  group_by(species_id) %>%
  summarize(med_weight = median(weight)) %>%
  # Output is no longer a dataframe, but a "tibble", which cuts itself short pretty soon; so
  # to see the whole "tibble", you'd have to add a print command at the end:
  print(n=25)

# Removing NA's:
surveys_complete <- surveys %>%
   filter(!is.na(weight),
     species_id != '',
     !is.na(hindfoot_length),
      sex != '',
     taxa == 'Rodent')

# Species that appear 50 or more times in the data:
common_species <- surveys_comlete %>%
    group_by(species_id) %>%
    tally() %>%
    filter(n >= 50) %>%
    select(species_id)

common_surveys <- surveys_complete %>%
   filter(species_id %in% common_species$species_id)

write.csv(common_surveys, file = '~/Desktop/surveys_complete.csv', row.names = FALSE)

# now ggplot2 ("gg" = "grammar of graphics")
# NEED TO SPECIFY THE AESTHETICS: x axis, y axis, etc.
# don't forget + sign to add the plot layer
library(ggplot2)
ggplot(data=surveys)
# OR
ggplot(data=surveys, 
       aes(
         x=weight, 
         y=hindfoot_length,
         color = species_id)) +
  geom_point()
#saves the workspace, but does not include the plot
save.image("/home/barroso/Desktop/Rpractice.RData")
# re-loads the workspace
load('/home/barroso/Desktop/Rpractice.RData')
# + theme_bw()  ... can be added to the ggplot statement
