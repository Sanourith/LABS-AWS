PREPARE LE TERMINAL :
sudo yum install nano -y
curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/v0.177.0/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version

export VERIFY_CHECKSUM=false
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

===========
eksctl create cluster -f Infrastructure/eksctl/01-initial-cluster/cluster.yaml
===========

-- LOAD BALANCER CONTROLLER --

Dans LABS-AWS/infrastructure/k8s-tooling/load-balancer-controller 

create.sh :
#! /bin/bash
helm repo add eks https://aws.github.io/eks-charts

helm upgrade --install \
  -n kube-system \
  --set clusterName=eks-acg \
  --set serviceAccount.create=true \
  aws-load-balancer-controller eks/aws-load-balancer-controller

aws cloudformation deploy \
    --stack-name aws-load-balancer-iam-policy \
    --template-file iam-policy.yaml \
    --capabilities CAPABILITY_IAM

==== config l'ALB
Dans l'interface graphique ; VPC > LoadBalancer, récup le nom du loadB
Récup son "nom" pour l'intégrer aux IAM policies / ensuite, on lance le DNS de notre LB et on arrive sur NGINX ;

Dans test/run.sh
on installe l'app sample-app et on va pouvoir la tester en SSL

cf templates/ingress.yaml :

#   annotations:
#     alb.ingress.kubernetes.io/group.name: my-group
#     alb.ingress.kubernetes.io/scheme: internet-facing
# {{- if not .Values.ssl.enabled }}
#     alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}]'
# {{- else }}
#     alb.ingress.kubernetes.io/ssl-redirect: '443'
#     alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
# {{- end }}
#   labels:
#     app: nginx
# spec:
#   ingressClassName: alb #traefik

=== routage du 80 vers le 443 automatique.

SSL certificate :
infrastructure/cloudformation/ssl-certificate
#On a scripté l'utilisation du acm.yaml :

# Description: ACM Certificate
# Parameters:
#   DomainName:
#     Description: The base Domain Name
#     Type: String
#   HostedZoneId:
#     Description: The Hosted ID to validate the certificate
#     Type: String
# Resources:
#   Certificate:
#     Type: AWS::CertificateManager::Certificate
#     Properties:
#       DomainName: !Sub "*.${DomainName}"
#       SubjectAlternativeNames: 
#         - !Ref DomainName
#       ValidationMethod: DNS
#       DomainValidationOptions:
#         - DomainName: !Ref DomainName
#           HostedZoneId: !Ref HostedZoneId
#       Tags:
#         - Key: Name
#           Value: !Ref DomainName

######           ROUTE 53            ######
Cloudformation : ssl certificate, lancer le # create.sh
### Successfully created/updated stack - ssl-certificate ###

MENU : ACM (certif manager)
menu gauche : list
on voit notre nouveau certificat.

===> on va redéployer load-balancer-controller avec les paramètres SSL ;
Le script va intégrer le "HOST" en nom de domaine (tout le reste revient KO par sécurité)
load-balancer-controller/test/run-with-ssl.sh 

EC2/LoadBalancer
on récup le nom de l'app dans le domaine (cf les rules en bas)
ROUTE53 : clic sur la route
CREATE RECORD : sample-app (le .suite s'affiche tout seul)
COCHER ALIAS == route traffic to LOAD BALANCER / region we are.
CREATE records.

###### AUTOMATING DNS MANAGEMENT ######
DNS creation is manual = too much effort.

EXTERNAL DNS for Kubernetes / IAM Policy pour créer des records.
==== ADJUST IAM PERMISSIONS / INSTALL EXTERNAL DNS
=== On supprime la route53 créée manuellement
=== On lance le script :
infrastructure/k8s-tooling/external-dns/create.sh
# helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
# helm upgrade --install external-dns external-dns/external-dns

=> crée un pod externalDNS
CLOUDFORMATION (graphique)
nodegroup-eks stack, dans resources/ NodeInstanceRole
Add permissions : AmazonRoute53FullAccess (va le retrouver)
==== si on pète le pod external, il va être recréé avec les droits IAM.

####  ROUTE53
hosted zones
sample-app.dnsrecord



