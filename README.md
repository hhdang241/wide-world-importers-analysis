# Wide World Importers - Product Analysis
## Wide World Importers

WWI is a wholesale novelty goods importer and distributor operating from the San Francisco bay area.

Here is the official link to the SQL [database](https://learn.microsoft.com/en-us/sql/samples/wide-world-importers-what-is?view=sql-server-ver16).

To better understand the dataset, check [here](https://dataedo.com/samples/html/WideWorldImporters/doc/WideWorldImporters_5/views/Website_Customers_3842.html).

## Approach

1. First, SQL was used to create the 'Product' table which detailed qualitative and quantitative data at the granularity level of Stock Item ID. We'd like to see a breakdown of sales success per category > subcategory > product > size/color.

2. Next, SQL was then used to create 'Time' table which will compare transformations of revenue and profit over time.
 
3. Regex was implemented to standardize StockItemName in 'Product' table, and to categorize it in both tables.
 
4. Finally, the two dataframes were exported from SSMS and imported to Power BI.
 
5. The complete dashboard features three pages via sidebar navigation buttons, modular visualizations via filter parameters, and hover tooltips on most graphics and text boxes.

## Data Insights

**New products - New priorities:** In 2016, we added 7 new products in a brand new Candy category. We may need to reconsider how we chose to allocate our resources. It's likely that our ad spend, human resources, and social media efforts were redistributed to promote this new array of products. As proven by our steep decline, our current arrangement is unsustainable. *see Line Chart*

- Is the new Candy category spreading our resources too thin?

Profit per product can be seen in this box plot to evaluate the efficacy of the Candy category as a whole. A higher concentration of points near the LQ is not a great indication for the success of these products, but more data points would be necessary to reach a more accurate conclusion. (see i bubble on Dashboard Home Sidebar)
