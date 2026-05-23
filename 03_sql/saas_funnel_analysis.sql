-- =====================================================
-- 1. Basic Validation & Top-Level Funnel Overview
-- Establishes the baseline volume of users across key lifecycle stages. 
-- Note: While useful for macro-level tracking, these aggregate metrics 
-- often mask segment-level inefficiencies within the onboarding flow.
-- =====================================================
SELECT COUNT(*) FROM saas_funnel;

SELECT
	SUM(is_activated) AS activated_users,
    SUM(is_converted) AS converted_users,
    SUM(is_churned) AS churned_users
FROM saas_funnel;

-- =====================================================
-- 2. Aggregate Funnel Analysis (Drop-offs)
-- Calculates the overall transition rates between lifecycle stages.
-- Serves as a starting point before drilling down into specific 
-- behavioral or channel-based segments to find monetization gaps.
-- =====================================================
SELECT
	SUM(is_activated) AS activated_users,
    SUM(is_converted) AS converted_users,
    SUM(is_churned) AS churned_users,

	ROUND(SUM(is_activated)/COUNT(*)*100, 2) AS activation_rate,
    ROUND(SUM(is_converted)/SUM(is_activated)*100, 2) AS conversion_rate,
    ROUND(SUM(is_churned)/COUNT(*)*100, 2) AS churn_rate
FROM saas_funnel;

-- =====================================================
-- 3. Stage-wise Drop-off Analysis
-- Isolates the exact transition points where user momentum stalls.
-- Helps product teams identify whether the early onboarding flow (Signup → Activation) 
-- or the value realization phase (Activation → Conversion) contains deeper inefficiencies.
-- =====================================================
SELECT
	'Signup → Activation' AS stage,
    COUNT(*) - SUM(is_activated) AS drop_off
FROM saas_funnel

UNION

SELECT
	'Activation → Conversion',
    SUM(is_activated) - SUM(is_converted)
FROM saas_funnel;

-- =====================================================
-- 4. Activation → Conversion Impact
-- Tests the hypothesis that reaching the specific "Activation" milestone 
-- drives higher monetization yield. Compares conversion rates of 
-- activated vs. non-activated users to measure product onboarding effectiveness.
-- =====================================================
SELECT
	is_activated,
    COUNT(*) AS users,
    SUM(is_converted) AS conversions,
    ROUND(SUM(is_converted)/COUNT(*)*100, 2) AS conversion_rate
FROM saas_funnel
GROUP BY is_activated;

-- =====================================================
-- 5. Segment-Level Analysis: Channel Performance
-- Evaluates acquisition channels not just on signup volume, but on their 
-- ultimate monetization yield (conversion rate) and retention (churn rate). 
-- Crucial for identifying high-intent traffic sources vs. inefficient ad spend.
-- =====================================================
SELECT
	acquisition_channel,
    COUNT(*) AS users,
    SUM(is_converted) AS conversions,
    ROUND(SUM(is_converted)/COUNT(*)*100, 2) AS conversion_rate,
    ROUND(SUM(is_churned)/COUNT(*)*100, 2) AS churn_rate
FROM saas_funnel
GROUP BY acquisition_channel
ORDER BY conversion_rate DESC;

-- =====================================================
-- 6. Segment-Level Analysis: Engagement Tiers
-- Segments users by session frequency to expose behavioral thresholds.
-- Determines the level of platform engagement required to 
-- reliably predict a successful paid conversion.
-- =====================================================
SELECT
	CASE
		WHEN sessions_count <= 3 THEN 'Low'
		WHEN sessions_count <= 7 THEN 'Medium'
		ELSE 'High'
	END AS engagement_level,
	
    COUNT(*) AS users,
    SUM(is_converted) AS conversions,
    ROUND(SUM(is_converted)/COUNT(*)*100, 2) AS conversion_rate
FROM saas_funnel
GROUP BY engagement_level;

-- =====================================================
-- 7. Time to Convert (Velocity Metrics)
-- Measures the time delay between user acquisition and monetization.
-- Helps assess whether the sales cycle / trial period is optimal 
-- or if users are lingering in the funnel without realizing value quickly.
-- =====================================================
SELECT
	ROUND(AVG(days_to_convert)) AS avg_days_to_convert,
    MIN(days_to_convert) AS min_days,
    MAX(days_to_convert) AS max_days
FROM saas_funnel
WHERE is_converted = 1;

-- =====================================================
-- 8. Segment-Level Churn Analysis
-- Categorizes churned users by their time-to-churn to detect 
-- early warning signals. A high early-churn volume (0-7 days) 
-- indicates immediate onboarding failures or mismatched product expectations.
-- =====================================================
SELECT
	CASE
		WHEN time_to_churn <= 7 THEN '0-7 days'
        WHEN time_to_churn <= 30 THEN '8-30 days'
        ELSE '30+ days'
	END AS churn_bucket,
    COUNT(*) AS users
FROM saas_funnel
WHERE is_churned = 1
GROUP BY churn_bucket;

-- =====================================================
-- Converted vs Non-converted Churn Impact
-- Contrasts the retention behavior of paying vs. free users.
-- Evaluates if the platform's core value proposition successfully 
-- minimizes churn risk once users are monetized.
-- =====================================================
SELECT
	is_converted,
    COUNT(*) AS users,
    SUM(is_churned) AS churned,
    ROUND(SUM(is_churned)/COUNT(*)*100, 2) AS churn_rate
FROM saas_funnel;

-- =====================================================
-- 9. Cohort Analysis
-- Tracks conversion success across monthly acquisition segments.
-- Highlights seasonal dynamics and measures if recent product/marketing 
-- updates have positively impacted funnel yield over time.
-- =====================================================
SELECT
	cohort_month,
    COUNT(*) AS users,
    SUM(is_converted) AS conversions,
    ROUND(SUM(is_converted)/COUNT(*)*100, 2) AS conversion_rate
FROM saas_funnel
GROUP BY cohort_month
ORDER BY cohort_month;

-- =====================================================
-- 10. Monetization Yield: Revenue Analysis
-- Directly assesses the financial impact of the funnel by plan tier.
-- Identifies which product offerings generate the highest financial return,
-- guiding future pricing, feature gating, and upselling strategies.
-- =====================================================
SELECT
	plan_type,
    COUNT(*) AS users,
    SUM(revenue) AS total_revenue,
    AVG(revenue) AS avg_revenue
FROM saas_funnel
WHERE is_converted = 1
GROUP BY plan_type;

-- =====================================================
-- 11. High-Value User Profiling
-- Correlates deep engagement metrics (sessions and actions) with 
-- acquisition channels to build a profile of the ideal customer.
-- Reveals where the most profitable, high-yielding user segments originate.
-- =====================================================
SELECT
	acquisition_channel,
    AVG(sessions_count) AS avg_sessions,
    AVG(actions_count) AS avg_actions,
    ROUND(SUM(is_converted)/COUNT(*)*100,2) AS conversion_rate
FROM saas_funnel
GROUP BY acquisition_channel;

-- =====================================================
-- 12. Reporting Layer: Power BI Aggregation
-- Compiles the cleaned, structured data into an aggregated view 
-- optimized for downstream dashboarding. Enables visual drill-downs 
-- into channel and cohort performance to continuously monitor segment health.
-- =====================================================
CREATE VIEW funnel_summary AS
SELECT
    acquisition_channel,
    cohort_month,
    COUNT(*) AS users,
    SUM(is_activated) AS activated,
    SUM(is_converted) AS converted,
    SUM(is_churned) AS churned,
    SUM(revenue) AS revenue
FROM saas_funnel
GROUP BY acquisition_channel, cohort_month;
    