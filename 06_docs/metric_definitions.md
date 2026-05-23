# Metric Definitions

This document defines the core business metrics and KPIs used throughout the NexaFlow SaaS Funnel Analytics project.

---

## 1. Total Users

**Definition:**  
Total number of unique users who signed up for the platform.

**Formula:**  
```sql
COUNT(DISTINCT user_id)
```

---

## 2. Activated Users

**Definition:**  
Users who completed the platform activation step after signup.

**Business Meaning:**  
Measures onboarding effectiveness and early product engagement.

---

## 3. Activation Rate

**Definition:**  
Percentage of total users who became activated users.

**Formula:**  

```sql
(Activated Users / Total Users) * 100
```

**Business Importance:**  
Higher activation rates indicate successful onboarding experiences.

---

## 4. Converted Users

**Definition:**  
Users who upgraded to a paid subscription plan.

**Business Meaning:**  
Represents successful monetization of acquired users.

---

## 5. Conversion Rate

**Definition:**  
Percentage of activated users who converted into paying customers.

**Formula:**  

```sql
(Converted Users / Activated Users) * 100
```

**Business Importance:**  
Measures the effectiveness of the activation-to-purchase journey.

---

## 6. Overall Funnel Conversion Rate

**Definition:**  
Percentage of total signed-up users who became paying customers.

**Formula:**  

```sql
(Converted Users / Total Users) * 100
```

---

## 7. Churned Users

**Definition:**  
Users who discontinued platform usage or subscription.

**Business Meaning:**  
Represents customer loss over time.

---

## 8. Churn Rate

**Definition:**  
Percentage of users who churned.

**Formula:**  

```sql
(Churned Users / Total Users) * 100
```

**Business Importance:**  
A critical SaaS metric used to evaluate retention performance.

---

## 9. Days to Activate

**Definition:**  
Number of days taken by a user to activate after signup.

**Formula:**  

```sql
activation_date - signup_date
```

---

## 10. Days to Convert

**Definition:**  
Number of days taken for an activated user to purchase a subscription.

**Formula:**  

```sql
subscription_date - activation_date
```

---

## 11. Active Days

**Definition:**  
Total number of days a user remained active on the platform.

**Business Importance:**  
Used to understand user engagement and retention behavior.

---

## 12. Revenue

**Definition:**  
Total subscription revenue generated from converted users.

**Business Meaning:**  
Primary monetization metric used to evaluate business growth.

---