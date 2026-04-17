# 🚨 Runbook : Réponse aux Incidents Data

Ce document décrit les étapes à suivre en cas de défaillance de la pipeline de données.

## 1. Détection
- **Alertes Airflow** : Notification Slack/Email en cas d'échec de DAG.
- **Dbt Cloud/Core** : Échec des tests de données (Data Quality).
- **MinIO/Kafka** : Alertes de latence ou d'indisponibilité.

## 2. Diagnostic Initial
1. Vérifier les logs du conteneur défaillant : `docker-compose logs <service_name>`.
2. Pour dbt : Inspecter `logs/dbt.log` ou les artefacts de la CI.
3. Pour Kafka : Vérifier l'état du connecteur Debezium.

## 3. Procédures de Résolution
### Échec de dbt Test
- **Cause** : Données sources malformées ou doublons.
- **Action** : Identifier les enregistrements fautifs via la requête SQL générée par dbt. Communiquer avec l'équipe source.

### Latence Kafka
- **Cause** : Backpressure ou consommateur lent.
- **Action** : Vérifier le "consumer lag". Redémarrer le service `consumer` si nécessaire.

## 4. Post-Mortem
Chaque incident critique doit faire l'objet d'un court rapport :
- Cause racine.
- Action corrective immédiate.
- Action préventive à long terme.
