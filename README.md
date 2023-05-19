DomoR
=======

I've forked this repo to fix the httr version bug.

```
install.packages("devtools")
library("devtools")
install_github(repo="EAVWing/DomoR")
```
```
DomoR::init('customer', 'token')

DomoR::list_ds()

```
### Fetch
Fetch the data source by using the index from the most previous `list_ds()` results:
```
df <- DomoR::fetch(1)
```
Or specify a data source ID directly
```
df <- DomoR::fetch('48d49aa4-6e03-451a-906b-2aa6610dbd55')
```
Make sure and assign the fetched data source to a (data frame) variable so you can manipulate the data.  If you don't specify a variable to assign it to, the data source is output to the console.

### Create
Create a data source by passing in a data frame with a name and description (where `df` is your data frame variable from which you'll create a data source in Domo).
```
DomoR::create(df, name="My Data Source Name", description="My Data Source Description")
```

### Replace
Replace an existing data source (and update schema if necessary). This command is available only for DataSets that were created using the R plugin or Domo Streams API.

```
DomoR:replace_ds('ab84f24a-73d4-0188-d8aa-8fe78103a721', df)
```

A warning will appear on the console if the schema was updated/changed.
