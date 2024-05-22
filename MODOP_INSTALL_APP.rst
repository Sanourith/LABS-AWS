Dans notre fichier d'app :

APP-NAME :
    docs
        example.json
    infra
        _archived
        cloudformation
            create_db.sh
            db_table.yaml
        codebuild
            deployment
                buildspec.yaml
            buildspec.yaml
        helm1
            templates
                deploy
                etc...
            Chart.yaml
            values.yaml
            create.sh
        helm2
        etc...
    src
    version


1/ CREATE DBs

dans le terminal AWS :
cd dossier-app1/infra/cloudformation 
    create_db.sh script
===> pour chaque service de l'app !

Les dynamoDB sont créées (menu / DynamoDB / list)

IAM dynamoDB permissions à faire :
    Cloudformation 
        NodeGroup stacks / resources
            NodeInstanceRole / add policy :
                AmazonDynamoDBFullAccess


2/ Install micro-services requis pour l'app
dans chaque service : 
    infra/helm
        docs/helm 
            values.yaml : check base domain / region / repository.
            create.sh : install la helm chart.

On lance le create.sh dans chaque application
Tous les pods sont créés + ingresses
(kubectl get pods/ingresses)

On va dans EC2 / load balancers /listeners
HTTP & HTTPS
clic "rules"
on voit les règles pour chaque pods dans l'ALB.
Un seul ALB pour chaque API.

Si on regarde les ingress :
kubectl describe ingress "nom de l'ingress" -n namespace
annoatation : group.name = development

kubectl describe ingress NAMESPACE 
annotation group.name "development"

Si on refait avec d'autres services : les services ont les mêmes noms. Le même ALB avec les ingress.


ROUTE53 :
hosted zone :
on a PLEIN de routes qui sont créées toutes seules.
