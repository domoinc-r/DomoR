DomoR
=======

An R package for interacting with Domo data sources

## About R
[R](http://www.r-project.org/) is a programming language and development environment that is specifically built for statistical computing and graphics.  It's one of the [fastest growing programming languages](http://www.tiobe.com/index.php/content/paperinfo/tpci/index.html) in 2014.  It has an amazing library of rich, statistics related packages.  It is deeply ingrained in academia and generally makes doing hard statistical analysis seem easy.

## Prerequisites
In order to work with data sources directly from Domo, you need to setup your R environment.

* [Download R](http://www.r-project.org)
* (Optional) [Download R Studio](http://www.rstudio.com) (an Eclipse based IDE)

## Installation
As DomoR is not yet published on [CRAN](http://cran.r-project.org/mirrors.html), the Comprehensive R Archive Network (and may never be), you need a helper package to install it.  [Hadley Wickham](http://had.co.nz/) has built a fantastic library called [devtools](https://github.com/hadley/devtools) that allows you to install an R package directly from Github.

To install and load `devtools`, from an R command prompt, run:
```
install.packages("devtools")
library("devtools")
```
You can verify that you have `devtools` installed correctly by checking `has_devel()` and verify that the last line is `TRUE`.
```
has_devel()
'/Library/Frameworks/R.framework/Resources/bin/R' --vanilla CMD SHLIB foo.c

clang -I/Library/Frameworks/R.framework/Resources/include -DNDEBUG  -I/usr/local/include -I/usr/local/include/freetype2 -I/opt/X11/include    -fPIC  -Wall -mtune=core2 -g -O2  -c foo.c -o foo.o
clang -dynamiclib -Wl,-headerpad_max_install_names -undefined dynamic_lookup -single_module -multiply_defined suppress -L/usr/local/lib -o foo.so foo.o -F/Library/Frameworks/R.framework/.. -framework R -Wl,-framework -Wl,CoreFoundation
[1] TRUE
```

After you have the `devtools` installed, you need to install the DomoR library.

#### Installation method from GitHub

You can install directly from our public Github repository:
  ```
  install_github(repo="domoinc-r/DomoR")
  ```

#### Installation method from filesystem
The easy way is to manually download and install from your filesystem.
  * Download the code using git to your local filesystem.  Make sure and keep the directory named `DomoR`.
  ```bash
  cd /tmp
  git clone https://github.com/domoinc-r/DomoR.git
  ```
  * From R, set your working directory to the parent directory where you cloned the repository, run
  ```
  setwd('/tmp')
  ```
  * Install the library
  ```
  install('DomoR')
  ```
  * Load the library
  ```
  library('DomoR')
  ```
  

## Example Usage
When using the DomoR package, the first thing you'll need to do is to initialize the development environment with your Domo customer instance (i.e. `CUSTOMER.domo.com` for https://CUSTOMER.domo.com) and your API access token.  To generate an API access token, log in to your Domo instance ***as an admin*** and go to [Admin > Security > Access Tokens](https://domo.domo.com/admin/security/accesstokens)

Once you have your token generated from the Domo Admin screen, initialize your development environment with:
```
DomoR::init('customer', 'token')
```

After you have initialized your development environment, there are essentially three simple things you can do:
* list your data sources
* fetch a data source and convert it to a data frame
* create a data source by uploading your data frame

### List
From there, you can then list all your data sources
```
> DomoR::list_ds()
                   Name                       Data Source ID
1           bullet.xlsx a02f0cdf-d1a4-4d75-9729-8135e499a8d9
2          bullet excel 87703789-3778-4882-ad9a-00514fd55e5b
3 bullet excel vertical 014cfa9c-7aa3-4b24-acaf-f90c768542d9
4     horizontal bullet 48d49aa4-6e03-451a-906b-2aa6610dbd55
>
```
The data source ID (third column) can be used to explicitly fetch a data source.  For convenience, the index (first column) can also be used to reference a data source to be fetched.  Please be careful as using the index (first column) will always fetch the data source from the most recent listing.

You can also provide various arguments that will narrow the results returned.  See the function documentation `?list_ds` (or `?DomoR::list_ds`) for more examples and a better description.

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

### Note
DomoR depends on <=httr_1.0.0 version. To download earlier version of httr please run below command

```
install.packages('http://cran.r-project.org/src/contrib/Archive/httr/httr_1.0.0.tar.gz', repos=NULL, type="source")
```
