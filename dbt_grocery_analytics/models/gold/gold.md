{% docs fct_grocery_basket_price %}
### Overview
One row per product per extraction date time. 

This table contains information about prices of products of interest.

---

### ERD
![grocery_basket_price_tracking](assets/star_schema.png)

---

### Useful Queries
#### Grocery basket price tracking

```sql
select 
    prd.product_name,
    p.price,
    p.extraction_time
from grocery_analytics.public.fct_grocery_basket_price p join grocery_analytics.public.dim_product prd
    on p.product_key = prd.product_key
```
{% enddocs %}


{% docs fct_specials_price %}
### Overview
One row per product per extraction date time. 

This table contains information about prices of products which are on half-price specials.

---

### Useful Queries
#### Specials price tracking

```sql
select 
    prd.product_name,
    p.price,
    p.extraction_time
from grocery_analytics.public.fct_specials_price p join grocery_analytics.public.dim_product prd
    on p.product_key = prd.product_key
```
{% enddocs %}