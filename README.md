# Complete deployement from scratch with Vagrant file 

## Prerequisites

- Vagrant
- VirtualBox

## Run the project

```
git clone https://github.com/czantoine/kubernetes-full-auto-deployement.git

cd kubernetes-full-auto-deployement
```

Execute " vagrant up master " and go get a cup of coffee

## Catch port

Prompt port :

``` shell
sudo kubectl get srv 
```

``` command prompt 
NAME            TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
flask-service   LoadBalancer   10.100.49.123   <pending>     5000:32744/TCP   82s
kubernetes      ClusterIP      10.96.0.1       <none>        443/TCP          8m19s
mysql           NodePort       10.108.68.102   <none>        3306:30703/TCP   83s
```

Catch port : 32744 

## Web browser 

Go on your favorite web browser 

``` 192.168.56.30:<port> ```

Try with the following commands:

``` 192.168.56.30:<port>/pokemons ```

Add data to the database

``` curl -H "Content-Type: application/json" -d '{"name": "dracolosse", "name_en": "dragoran", "number": "149"}' 192.168.56.30:<port>/create ```

Try to access the new data 

``` 192.168.56.30:<port>/pokemons ```

``` 192.168.56.30:<port>/pokemon/1 ```

Delete data to the database

``` curl -H "Content-Type: application/json" 192.168.56.30:<port>/delete/1 ```
