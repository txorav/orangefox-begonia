#ifndef WPAS_HIDL_H
#define WPAS_HIDL_H

#include <stddef.h>

struct wpas_hidl_priv;
struct wpa_global;
struct wpa_supplicant;
struct wpa_ssid;
struct rsn_pmksa_cache_entry;
struct wpa_bss_anqp;

static inline struct wpas_hidl_priv *wpas_hidl_init(struct wpa_global *global) { (void)global; return (struct wpas_hidl_priv *)1; }
static inline void wpas_hidl_deinit(struct wpas_hidl_priv *priv) { (void)priv; }
static inline int wpas_hidl_register_interface(struct wpa_supplicant *wpa_s) { (void)wpa_s; return 0; }
static inline int wpas_hidl_unregister_interface(struct wpa_supplicant *wpa_s) { (void)wpa_s; return 0; }
static inline int wpas_hidl_register_network(struct wpa_supplicant *wpa_s, struct wpa_ssid *ssid) { (void)wpa_s; (void)ssid; return 0; }
static inline int wpas_hidl_unregister_network(struct wpa_supplicant *wpa_s, struct wpa_ssid *ssid) { (void)wpa_s; (void)ssid; return 0; }

static inline void _wpas_hidl_ignore(int dummy, ...) { (void)dummy; }
#define _HIDL_STUB(...) _wpas_hidl_ignore(0, ##__VA_ARGS__)

#define wpas_hidl_notify_state_changed(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_disconnect_reason(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_assoc_reject(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_auth_timeout(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_bss_tm_status(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_bssid_changed(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_network_request(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_wps_event_fail(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_wps_event_success(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_wps_event_pbc_overlap(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_p2p_find_stopped(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_p2p_device_found(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_p2p_device_lost(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_p2p_group_removed(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_p2p_go_neg_req(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_p2p_go_neg_completed(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_p2p_invitation_result(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_p2p_sd_response(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_p2p_provision_discovery(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_p2p_group_started(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_p2p_group_formation_failure(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_p2p_invitation_received(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_ap_sta_authorized(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_ap_sta_deauthorized(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_eap_error(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_anqp_query_done(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_hs20_icon_query_done(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_hs20_rx_subscription_remediation(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_hs20_rx_deauth_imminent_notice(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_hs20_rx_terms_and_conditions_acceptance(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_dpp_config_received(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_dpp_config_sent(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_dpp_auth_success(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_dpp_resp_pending(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_dpp_not_compatible(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_dpp_missing_auth(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_dpp_configuration_failure(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_dpp_timeout(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_dpp_auth_failure(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_dpp_fail(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_dpp_config_sent_wait_response(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_dpp_config_accepted(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_dpp_conn_status(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_dpp_config_rejected(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_pmk_cache_added(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_transition_disable(...) _HIDL_STUB(__VA_ARGS__)
#define wpas_hidl_notify_network_not_found(...) _HIDL_STUB(__VA_ARGS__)

#endif /* WPAS_HIDL_H */
