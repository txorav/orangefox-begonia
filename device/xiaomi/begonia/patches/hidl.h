#ifndef WPAS_HIDL_H
#define WPAS_HIDL_H

#include <stddef.h>

struct wpas_hidl_priv;
struct wpa_global;
struct wpa_supplicant;
struct wpa_ssid;
struct rsn_pmksa_cache_entry;
struct wpa_bss_anqp;

static inline struct wpas_hidl_priv *wpas_hidl_init(struct wpa_global *global) { return (struct wpas_hidl_priv *)1; }
static inline void wpas_hidl_deinit(struct wpas_hidl_priv *priv) {}
static inline int wpas_hidl_register_interface(struct wpa_supplicant *wpa_s) { return 0; }
static inline int wpas_hidl_unregister_interface(struct wpa_supplicant *wpa_s) { return 0; }
static inline int wpas_hidl_register_network(struct wpa_supplicant *wpa_s, struct wpa_ssid *ssid) { return 0; }
static inline int wpas_hidl_unregister_network(struct wpa_supplicant *wpa_s, struct wpa_ssid *ssid) { return 0; }
static inline void wpas_hidl_notify_state_changed(struct wpa_supplicant *wpa_s) {}
static inline void wpas_hidl_notify_disconnect_reason(struct wpa_supplicant *wpa_s) {}
static inline void wpas_hidl_notify_assoc_reject(struct wpa_supplicant *wpa_s, const void *bssid, int timed_out, const void *assoc_resp_ie, size_t assoc_resp_ie_len) {}
static inline void wpas_hidl_notify_auth_timeout(struct wpa_supplicant *wpa_s) {}
static inline void wpas_hidl_notify_bss_tm_status(struct wpa_supplicant *wpa_s) {}
static inline void wpas_hidl_notify_bssid_changed(struct wpa_supplicant *wpa_s) {}
static inline void wpas_hidl_notify_network_request(struct wpa_supplicant *wpa_s, struct wpa_ssid *ssid, int rtype, const char *default_txt) {}
static inline void wpas_hidl_notify_wps_event_fail(struct wpa_supplicant *wpa_s, const void *peer_macaddr, int config_error, int error_indication) {}
static inline void wpas_hidl_notify_wps_event_success(struct wpa_supplicant *wpa_s) {}
static inline void wpas_hidl_notify_wps_event_pbc_overlap(struct wpa_supplicant *wpa_s) {}
static inline void wpas_hidl_notify_p2p_find_stopped(struct wpa_supplicant *wpa_s) {}
static inline void wpas_hidl_notify_p2p_device_found(struct wpa_supplicant *wpa_s, const void *addr, const void *info, int new_device) {}
static inline void wpas_hidl_notify_p2p_device_lost(struct wpa_supplicant *wpa_s, const void *dev_addr) {}
static inline void wpas_hidl_notify_p2p_group_removed(struct wpa_supplicant *wpa_s, const char *ssid, const char *role) {}
static inline void wpas_hidl_notify_p2p_go_neg_req(struct wpa_supplicant *wpa_s, const void *src, int dev_passwd_id, int go_intent) {}
static inline void wpas_hidl_notify_p2p_go_neg_completed(struct wpa_supplicant *wpa_s, void *res) {}
static inline void wpas_hidl_notify_p2p_invitation_result(struct wpa_supplicant *wpa_s, int status, const void *bssid) {}
static inline void wpas_hidl_notify_p2p_sd_response(struct wpa_supplicant *wpa_s, int sa, int update_indic, const void *tlvs, size_t tlvs_len) {}
static inline void wpas_hidl_notify_p2p_provision_discovery(struct wpa_supplicant *wpa_s, const void *dev_addr, int request, int config_methods, int generated_pin, const void *display_pin) {}
static inline void wpas_hidl_notify_p2p_group_started(struct wpa_supplicant *wpa_s, const void *ssid, int persistent, int client) {}
static inline void wpas_hidl_notify_p2p_group_formation_failure(struct wpa_supplicant *wpa_s, const char *reason) {}
static inline void wpas_hidl_notify_p2p_invitation_received(struct wpa_supplicant *wpa_s, const void *sa, const void *go_dev_addr, const void *bssid, int id, int op_freq) {}
static inline void wpas_hidl_notify_ap_sta_authorized(struct wpa_supplicant *wpa_s, const void *sta, const void *p2p_dev_addr) {}
static inline void wpas_hidl_notify_ap_sta_deauthorized(struct wpa_supplicant *wpa_s, const void *sta, const void *p2p_dev_addr) {}
static inline void wpas_hidl_notify_eap_error(struct wpa_supplicant *wpa_s, int error_code) {}
static inline void wpas_hidl_notify_anqp_query_done(struct wpa_supplicant *wpa_s, const void *bssid, const char *result, const struct wpa_bss_anqp *anqp) {}
static inline void wpas_hidl_notify_hs20_icon_query_done(struct wpa_supplicant *wpa_s, const void *bssid, const char *file_name, const void *image, size_t image_length) {}
static inline void wpas_hidl_notify_hs20_rx_subscription_remediation(struct wpa_supplicant *wpa_s, const char *url, int osu_method) {}
static inline void wpas_hidl_notify_hs20_rx_deauth_imminent_notice(struct wpa_supplicant *wpa_s, const void *code, int reauth_delay, const char *url) {}
static inline void wpas_hidl_notify_hs20_rx_terms_and_conditions_acceptance(struct wpa_supplicant *wpa_s, const char *url) {}
static inline void wpas_hidl_notify_dpp_config_received(struct wpa_supplicant *wpa_s, struct wpa_ssid *ssid) {}
static inline void wpas_hidl_notify_dpp_config_sent(struct wpa_supplicant *wpa_s) {}
static inline void wpas_hidl_notify_dpp_auth_success(struct wpa_supplicant *wpa_s) {}
static inline void wpas_hidl_notify_dpp_resp_pending(struct wpa_supplicant *wpa_s) {}
static inline void wpas_hidl_notify_dpp_not_compatible(struct wpa_supplicant *wpa_s) {}
static inline void wpas_hidl_notify_dpp_missing_auth(struct wpa_supplicant *wpa_s) {}
static inline void wpas_hidl_notify_dpp_configuration_failure(struct wpa_supplicant *wpa_s) {}
static inline void wpas_hidl_notify_dpp_timeout(struct wpa_supplicant *wpa_s) {}
static inline void wpas_hidl_notify_dpp_auth_failure(struct wpa_supplicant *wpa_s) {}
static inline void wpas_hidl_notify_dpp_fail(struct wpa_supplicant *wpa_s) {}
static inline void wpas_hidl_notify_dpp_config_sent_wait_response(struct wpa_supplicant *wpa_s) {}
static inline void wpas_hidl_notify_dpp_config_accepted(struct wpa_supplicant *wpa_s) {}
static inline void wpas_hidl_notify_dpp_conn_status(struct wpa_supplicant *wpa_s, int status, const char *ssid, const char *channel_list, unsigned short band_list[], int size) {}
static inline void wpas_hidl_notify_dpp_config_rejected(struct wpa_supplicant *wpa_s) {}
static inline void wpas_hidl_notify_pmk_cache_added(struct wpa_supplicant *wpas, struct rsn_pmksa_cache_entry *pmksa_entry) {}
static inline void wpas_hidl_notify_transition_disable(struct wpa_supplicant *wpa_s, struct wpa_ssid *ssid, unsigned char bitmap) {}
static inline void wpas_hidl_notify_network_not_found(struct wpa_supplicant *wpa_s) {}

#endif /* WPAS_HIDL_H */
