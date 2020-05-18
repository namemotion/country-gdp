mkdir temp
cd temp

status=$(curl --write-out %{http_code} --silent http://api.worldbank.org/v2/en/indicator/NY.GDP.MKTP.CD?downloadformat=csv -o wbgdp.zip)
if  [ $status -eq 200 ]; then
	unzip wbgdp.zip
	rm ../WBGDP.csv
	cut --delimiter="," -f2,63 API_NY.GDP.MKTP.CD_DS2_en_csv_v2_* | grep -E '"[A-Z]{3}",".*"' | sed -r 's/"//g' | sed -r 's/,/;/g' | sort -k 1 -t ";" > ../WBGDP.csv
fi

status=$(curl --write-out %{http_code} --silent https://raw.githubusercontent.com/lorey/list-of-countries/master/csv/countries.csv -o countryTemp.csv)
if [ $status -eq 200 ]; then
	rm ../countryList.csv
	sed -i'' 1d countryTemp.csv
	cut -d";" -f1,2,5,6,11,12,16,19 countryTemp.csv | sort -k 2 -t ";" > ../countryList.csv
fi

echo "COUNTRY-3;PIB;COUNTRY-2;ECONOMIC AREA;LANGUAGES;NAME;POPULATION;TLD" > ../countryGDP.csv
join -t ";" -1 1 -2 2 ../WBGDP.csv ../countryList.csv | cut --delimiter=";" -f1,2,3,4,6,7,8,9 >> ../countryGDP.csv 

cd ..
rm -rf temp