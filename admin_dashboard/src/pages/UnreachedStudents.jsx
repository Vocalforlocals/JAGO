import React, { useState, useEffect } from 'react';
import { 
  Users, 
  Send, 
  ShieldAlert, 
  CheckCircle2, 
  Search, 
  Building2, 
  PhoneCall, 
  Sparkles,
  MapPin,
  Radio,
  Truck,
  Languages,
  Filter,
  Layers,
  TrendingUp,
  X
} from 'lucide-react';
import { adminApi } from '../services/adminApi';

export default function UnreachedStudents() {
  const [students, setStudents] = useState([]);
  const [metrics, setMetrics] = useState(null);
  const [loading, setLoading] = useState(true);
  const [outreachToast, setOutreachToast] = useState(null);
  const [dispatching, setDispatching] = useState(false);
  const [search, setSearch] = useState('');
  const [isModalOpen, setIsModalOpen] = useState(false);

  // Outreach form state
  const [campaignName, setCampaignName] = useState('National Scholarship Saturation Drive');
  const [selectedChannel, setSelectedChannel] = useState('csc_mobile_camp');
  const [selectedLanguage, setSelectedLanguage] = useState('hi');
  const [targetDistrict, setTargetDistrict] = useState('All Districts');

  useEffect(() => {
    async function loadData() {
      setLoading(true);
      const [studentData, metricsData] = await Promise.all([
        adminApi.getUnreachedStudents(),
        adminApi.getSaturationMetrics()
      ]);
      setStudents(studentData);
      setMetrics(metricsData);
      setLoading(false);
    }
    loadData();
  }, []);

  const handleSendOutreach = async () => {
    setDispatching(true);
    const payload = {
      campaign_name: campaignName,
      channel: selectedChannel,
      language: selectedLanguage,
      target_district: targetDistrict
    };
    const res = await adminApi.triggerOutreach(payload);
    setDispatching(false);
    setIsModalOpen(false);

    setOutreachToast({
      message: res.message || 'Outreach campaign successfully dispatched!',
      campaignId: res.campaign_id || 'CAMP-2026-SAT-088',
      preview: res.sample_sms_preview,
      camps: res.csc_field_camps_scheduled || 8
    });

    setTimeout(() => setOutreachToast(null), 8000);
  };

  const filteredStudents = students.filter(s => 
    s.name.toLowerCase().includes(search.toLowerCase()) ||
    s.state.toLowerCase().includes(search.toLowerCase()) ||
    s.grade_class.toLowerCase().includes(search.toLowerCase()) ||
    s.udise_apaar_id.toLowerCase().includes(search.toLowerCase()) ||
    s.district.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="p-8 space-y-6 max-w-7xl mx-auto">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <div className="flex items-center space-x-2">
            <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Potentially Unreached Students</h1>
            <span className="bg-amber-100 text-amber-800 text-xs px-2.5 py-0.5 rounded-full font-semibold border border-amber-300">
              Saturation Engine
            </span>
          </div>
          <p className="text-sm text-slate-500 mt-1">
            Cross-referencing UDISE+, APAAR, and OTR to identify enrolled tribal students missing scholarship benefits
          </p>
        </div>

        <div>
          <button
            onClick={() => setIsModalOpen(true)}
            className="inline-flex items-center px-4 py-2.5 rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-semibold shadow-sm transition"
          >
            <Send className="w-4 h-4 mr-2" />
            <span>Mobilize Field Outreach & Camps</span>
          </button>
        </div>
      </div>

      {/* Toast Banner */}
      {outreachToast && (
        <div className="bg-emerald-50 border border-emerald-300 rounded-xl p-4 space-y-2 text-xs text-emerald-950 shadow-sm animate-fade-in">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-2 font-bold text-emerald-800 text-sm">
              <CheckCircle2 className="w-5 h-5 text-emerald-600 shrink-0" />
              <span>{outreachToast.message}</span>
            </div>
            <button 
              onClick={() => setOutreachToast(null)}
              className="text-emerald-700 hover:text-emerald-900 font-bold"
            >
              ✕
            </button>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-2 pt-1 border-t border-emerald-200/60 text-slate-700">
            <div>
              <span className="font-semibold text-emerald-900">Campaign Reference: </span>
              <span className="font-mono">{outreachToast.campaignId}</span>
              <span className="ml-3 font-semibold text-emerald-900">CSC Field Vans Scheduled: </span>
              <span className="font-bold text-emerald-700">{outreachToast.camps}</span>
            </div>
            {outreachToast.preview && (
              <div className="italic text-slate-600 truncate">
                "{outreachToast.preview}"
              </div>
            )}
          </div>
        </div>
      )}

      {/* Saturation Progress Bar & Overview */}
      {metrics && (
        <div className="bg-white rounded-xl border border-slate-200/90 p-5 shadow-sm space-y-4">
          <div className="flex flex-col md:flex-row md:items-center justify-between gap-3">
            <div>
              <div className="flex items-center space-x-2">
                <TrendingUp className="w-4 h-4 text-emerald-600" />
                <span className="font-bold text-slate-800 text-sm">National Tribal Scholar Saturation Rate</span>
              </div>
              <p className="text-xs text-slate-500 mt-0.5">
                Proportion of identified eligible tribal scholars receiving direct DBT scholarship benefits
              </p>
            </div>
            <div className="text-right">
              <span className="text-2xl font-black text-emerald-600">{metrics.overall_saturation_rate}%</span>
              <span className="text-xs text-slate-400 block">Saturated Coverage</span>
            </div>
          </div>

          {/* Progress Bar */}
          <div className="w-full bg-slate-100 rounded-full h-3 overflow-hidden flex">
            <div 
              className="bg-emerald-600 h-full transition-all duration-500 rounded-full" 
              style={{ width: `${metrics.overall_saturation_rate}%` }}
            ></div>
          </div>

          {/* District Breakdown Cards */}
          <div className="pt-2">
            <span className="text-[11px] font-bold text-slate-400 uppercase tracking-wider block mb-2.5">
              Priority Tribal District Saturation Index
            </span>
            <div className="grid grid-cols-2 md:grid-cols-5 gap-3">
              {metrics.district_saturation.map((d) => (
                <div key={d.district} className="p-3 bg-slate-50 rounded-lg border border-slate-100 space-y-1">
                  <div className="flex items-center justify-between text-xs">
                    <span className="font-bold text-slate-800">{d.district}</span>
                    <span className={`px-1.5 py-0.2 rounded text-[10px] font-bold ${
                      d.priority === 'High' ? 'bg-rose-100 text-rose-700' : 'bg-slate-200 text-slate-700'
                    }`}>
                      {d.priority}
                    </span>
                  </div>
                  <div className="text-xs text-slate-500">
                    Gap: <strong className="text-amber-700">{d.gap}</strong> scholars
                  </div>
                  <div className="text-[11px] font-semibold text-emerald-700">
                    {d.rate}% Saturated
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* Explanation Box */}
      <div className="bg-white rounded-xl border border-slate-200/90 p-5 shadow-sm space-y-2 text-xs">
        <div className="flex items-center space-x-2 text-slate-900 font-bold text-sm">
          <ShieldAlert className="w-4 h-4 text-emerald-600" />
          <span>Identification Methodology & Important Disclaimer</span>
        </div>
        <p className="text-slate-600 leading-relaxed">
          This list is generated by matching scholarship registration data with <strong>UDISE+</strong> (School Education), <strong>APAAR</strong> (Academic Bank of Credits), and <strong>OTR</strong> (One Time Registration) information. These students are currently enrolled in recognized educational institutions but have no active record of receiving national scholarship disbursements.
        </p>
        <p className="text-amber-800 font-semibold bg-amber-50 p-2.5 rounded-lg border border-amber-200">
          ⚠️ Note: Identified students are NOT confirmed eligible — they require formal eligibility verification before final sanction.
        </p>
      </div>

      {/* Search Bar */}
      <div className="bg-white rounded-xl border border-slate-200/90 p-4 shadow-sm">
        <div className="relative max-w-md">
          <Search className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
          <input
            type="text"
            placeholder="Search by student name, state, district, or APAAR ID..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-9 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs text-slate-800 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:bg-white"
          />
        </div>
      </div>

      {/* Students Table */}
      <div className="bg-white rounded-xl border border-slate-200/90 shadow-sm overflow-hidden">
        {loading ? (
          <div className="p-12 text-center text-xs text-slate-500">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-600 mx-auto mb-2"></div>
            Loading unreached student cohort...
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-slate-50/80 text-slate-600 font-semibold border-b border-slate-200/80 uppercase tracking-wider text-[11px]">
                <tr>
                  <th className="py-3.5 px-6">Student Name</th>
                  <th className="py-3.5 px-6">Class / Level</th>
                  <th className="py-3.5 px-6">State & District</th>
                  <th className="py-3.5 px-6">Identifier (UDISE/APAAR)</th>
                  <th className="py-3.5 px-6">Current Benefits</th>
                  <th className="py-3.5 px-6">Source Registry</th>
                  <th className="py-3.5 px-6 text-right">Status</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {filteredStudents.map((st) => (
                  <tr key={st.id} className="hover:bg-slate-50/80 transition">
                    <td className="py-4 px-6 font-semibold text-slate-900">
                      {st.name}
                    </td>
                    <td className="py-4 px-6 text-slate-700">
                      <span className="bg-slate-100 px-2.5 py-1 rounded-md text-[11px] font-medium text-slate-700">
                        {st.grade_class}
                      </span>
                    </td>
                    <td className="py-4 px-6 text-slate-600">
                      <span className="flex items-center space-x-1">
                        <MapPin className="w-3.5 h-3.5 text-slate-400" />
                        <span>{st.state} ({st.district})</span>
                      </span>
                    </td>
                    <td className="py-4 px-6 font-mono text-[11px] text-slate-600">
                      {st.udise_apaar_id}
                    </td>
                    <td className="py-4 px-6">
                      <span className="text-slate-500 italic">{st.enrolled_benefit}</span>
                    </td>
                    <td className="py-4 px-6 text-slate-500">
                      {st.source_portal}
                    </td>
                    <td className="py-4 px-6 text-right">
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-amber-100 text-amber-800">
                        {st.status}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Outreach Mobilization Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/60 backdrop-blur-sm p-4 animate-fade-in">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl border border-slate-200 space-y-5">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100">
              <div className="flex items-center space-x-2">
                <div className="h-8 w-8 rounded-lg bg-emerald-100 text-emerald-700 flex items-center justify-center font-bold">
                  🚀
                </div>
                <div>
                  <h3 className="text-sm font-bold text-slate-900">Mobilize Saturation Field Outreach</h3>
                  <p className="text-[11px] text-slate-500">Dispatch alerts & field teams to unreached scholars</p>
                </div>
              </div>
              <button 
                onClick={() => setIsModalOpen(false)}
                className="text-slate-400 hover:text-slate-600 font-bold"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="space-y-4 text-xs">
              {/* Campaign Name */}
              <div>
                <label className="font-semibold text-slate-700 block mb-1">Campaign Title</label>
                <input
                  type="text"
                  value={campaignName}
                  onChange={(e) => setCampaignName(e.target.value)}
                  className="w-full px-3 py-2 border border-slate-200 rounded-lg text-slate-800 focus:ring-2 focus:ring-emerald-500 focus:outline-none"
                />
              </div>

              {/* Target District */}
              <div>
                <label className="font-semibold text-slate-700 block mb-1">Target District / Cluster</label>
                <select
                  value={targetDistrict}
                  onChange={(e) => setTargetDistrict(e.target.value)}
                  className="w-full px-3 py-2 border border-slate-200 rounded-lg text-slate-800 focus:ring-2 focus:ring-emerald-500 focus:outline-none bg-white"
                >
                  <option value="All Districts">All High-Priority Tribal Clusters (300 Scholars)</option>
                  <option value="Khunti">Khunti District (Priority: High)</option>
                  <option value="West Singhbhum">West Singhbhum (Priority: High)</option>
                  <option value="Gumla">Gumla District (Priority: Medium)</option>
                  <option value="Ranchi">Ranchi District (Priority: Medium)</option>
                  <option value="Mayurbhanj">Mayurbhanj District (Priority: Normal)</option>
                </select>
              </div>

              {/* Channel Selector */}
              <div>
                <label className="font-semibold text-slate-700 block mb-1">Mobilization Channel</label>
                <div className="grid grid-cols-1 gap-2">
                  <label className={`p-3 rounded-lg border flex items-center justify-between cursor-pointer transition ${
                    selectedChannel === 'csc_mobile_camp' ? 'border-emerald-500 bg-emerald-50/50' : 'border-slate-200'
                  }`}>
                    <div className="flex items-center space-x-2">
                      <Truck className="w-4 h-4 text-emerald-600" />
                      <div>
                        <span className="font-bold text-slate-800 block">CSC Mobile Field Van</span>
                        <span className="text-[11px] text-slate-500">Deploy biometrics van to remote Gram Panchayats</span>
                      </div>
                    </div>
                    <input 
                      type="radio" 
                      name="channel" 
                      checked={selectedChannel === 'csc_mobile_camp'} 
                      onChange={() => setSelectedChannel('csc_mobile_camp')} 
                    />
                  </label>

                  <label className={`p-3 rounded-lg border flex items-center justify-between cursor-pointer transition ${
                    selectedChannel === 'sms_regional' ? 'border-emerald-500 bg-emerald-50/50' : 'border-slate-200'
                  }`}>
                    <div className="flex items-center space-x-2">
                      <Radio className="w-4 h-4 text-emerald-600" />
                      <div>
                        <span className="font-bold text-slate-800 block">Regional SMS (CDAC Meghdoot)</span>
                        <span className="text-[11px] text-slate-500">Direct mobile broadcast to student SIMs</span>
                      </div>
                    </div>
                    <input 
                      type="radio" 
                      name="channel" 
                      checked={selectedChannel === 'sms_regional'} 
                      onChange={() => setSelectedChannel('sms_regional')} 
                    />
                  </label>
                </div>
              </div>

              {/* Language Selector */}
              <div>
                <label className="font-semibold text-slate-700 block mb-1">Broadcast Language</label>
                <div className="grid grid-cols-4 gap-2">
                  {[
                    { id: 'hi', label: 'Hindi (हिंदी)' },
                    { id: 'san', label: 'Santali (ᱥᱟᱱᱛᱟᱲᱤ)' },
                    { id: 'or', label: 'Odia (ଓଡ଼ିଆ)' },
                    { id: 'en', label: 'English' }
                  ].map((lang) => (
                    <button
                      key={lang.id}
                      type="button"
                      onClick={() => setSelectedLanguage(lang.id)}
                      className={`p-2 rounded-lg border text-center text-[11px] font-semibold transition ${
                        selectedLanguage === lang.id
                          ? 'border-emerald-600 bg-emerald-600 text-white shadow-sm'
                          : 'border-slate-200 bg-slate-50 text-slate-700 hover:bg-slate-100'
                      }`}
                    >
                      {lang.label}
                    </button>
                  ))}
                </div>
              </div>
            </div>

            {/* Modal Actions */}
            <div className="flex items-center justify-end space-x-3 pt-3 border-t border-slate-100">
              <button
                type="button"
                onClick={() => setIsModalOpen(false)}
                className="px-4 py-2 rounded-lg border border-slate-200 text-slate-600 hover:bg-slate-50 text-xs font-semibold"
              >
                Cancel
              </button>
              <button
                type="button"
                onClick={handleSendOutreach}
                disabled={dispatching}
                className="px-5 py-2 rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-semibold shadow-sm transition disabled:opacity-50 flex items-center space-x-2"
              >
                <Send className="w-3.5 h-3.5" />
                <span>{dispatching ? 'Mobilizing Field Teams...' : 'Execute Dispatch'}</span>
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Footer Note */}
      <div className="text-center text-xs text-slate-400 pt-2">
        This list requires eligibility verification. Not all identified students will qualify under current income caps.
      </div>
    </div>
  );
}
