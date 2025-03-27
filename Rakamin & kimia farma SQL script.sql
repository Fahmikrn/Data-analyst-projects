
/*
Prior starting the data transformation process, we can take a look of our imported tables by 
using following code. from all of those tables, we need to know the locations of requested columns
and choosing the would be primary key, foreign key, and alternate key.
*/

Select * from `rakamin-kf-analytics-454009.kimia_farma.kf_final_transaction`;
Select * from `rakamin-kf-analytics-454009.kimia_farma.kf_kantor_cabang`; 
Select * from `rakamin-kf-analytics-454009.kimia_farma.kf_product`;
Select * from `rakamin-kf-analytics-454009.kimia_farma.kf_inventory`;

/*
After we already have the Idea of therequested column's location in each table, 
we can start selecting those columns and plan on joining the tables. however, 
we have to keep in mind that There are so many approaches at our disposal
 */


CREATE TABLE rakamin-kf-analytics-454009.kimia_farma.tabel_analisis AS 

/*
The CREATE TABLE statement can be added after we have succesfully collected all
requested columns and tested our query whether it has satisfied our requirements.
/*/

SELECT transaction_id, date, 
  transaksi.branch_id, info_cabang.branch_name,
  info_cabang.kota, info_cabang.provinsi, 
  info_cabang.rating AS rating_cabang,transaksi.customer_name,
  transaksi.rating as rating_transaksi,
  transaksi.product_id,produk.product_name,
  transaksi.price AS actual_price, transaksi.discount_percentage,
    CASE # CASE WHEN is used for doing conditional expression in our query, returning specific values based on the conditions
     WHEN transaksi.price <= 50000 THEN 10/100
     WHEN transaksi.price BETWEEN 50000 AND 100000 THEN 15/100
     WHEN transaksi.price BETWEEN 100000 AND 300000 THEN 20/100
     WHEN transaksi.price BETWEEN 300000 AND 500000 THEN 25/100
     WHEN transaksi.price >= 500000 THEN 30/100
     ELSE null
     END AS persentase_gross_laba,
      (transaksi.price - (transaksi.price * discount_percentage)) AS nett_sales,
    #from the line above, we need to subtract the original price with discounted price to receive the actual sold products price

    /*There are three tables that store requested columns. We can JOIN them accordingly
    to our requirements
    */

      FROM `rakamin-kf-analytics-454009.kimia_farma.kf_final_transaction` as transaksi 
       LEFT JOIN `rakamin-kf-analytics-454009.kimia_farma.kf_kantor_cabang` as info_cabang 
         ON transaksi.branch_id = info_cabang.branch_id
       LEFT JOIN `rakamin-kf-analytics-454009.kimia_farma.kf_product` AS produk
         ON transaksi.product_id = produk.product_id;

/* After we have succesfully created and tested the query, We add the CREATE TABLE statement 
above as previously mentioned*/ 

/*However, due to calling an Alias of another columnis not working during 
the calculation of column such as 'persentase_gross_laba,
it can be a lot complex because of the intensive calculations 
(although it's possible, but we can't use alias
to simplify the calculation). in this case we can
alter the table by adding an empty collumn and update its values  */ 

ALTER TABLE `rakamin-kf-analytics-454009.kimia_farma.tabel_analisis`
  ADD COLUMN nett_profit FLOAT64;


UPDATE `rakamin-kf-analytics-454009.kimia_farma.tabel_analisis`
  SET nett_profit = nett_sales * persentase_gross_laba
  #the line above will calculate profit per product sold to customers based on profit percentages
    WHERE TRUE; #SET is only used for scalar value.

/* As we have successfully updated the tabel_analisis,
now let's see the table contents once again*/ 

SELECT * FROM `rakamin-kf-analytics-454009.kimia_farma.tabel_analisis`
ORDER BY nett_profit DESC
LIMIT 200000;

SELECT ROUND(nett_profit, 2) FROM `rakamin-kf-analytics-454009.kimia_farma.tabel_analisis`
ORDER BY nett_profit DESC
LIMIT 200000;


    
